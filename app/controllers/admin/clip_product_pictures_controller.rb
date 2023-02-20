class Admin::ClipProductPicturesController < AdminController
  require 'tmpdir'

  # TODO: add pagination

  def show_products_without_outfit_pictures
    @products = Product.without_outfit_pictures.page(params[:page] || 1).per(100)
  end

  def show_products_with_outfit_pictures
    @products = Product.with_outfit_pictures.page(params[:page] || 1).per(100)
  end

  def generate_zip
    pp_ids = params[:pictures].keys.map { |k| k.to_s.to_i }
    copied_files = []
    copied_file_paths = []
    pp_ids.each do |pp_id|
      pp = ProductPicture.find(pp_id)
      if pp.blank?
        Rails.logger.error("Missing ProductPicture with id #{pp_id}")
        next
      end

      f = Tempfile.new(["pp-#{pp_id}-", File.extname(pp.picture.path)])
      FileUtils.cp(pp.picture.path, f.path)
      copied_file_paths << f.path
      copied_files << f
      f.close
    end

    buffer = Zip::OutputStream.write_buffer do |stream|
      copied_file_paths.each do |file_path|
        stream.put_next_entry(File.basename(file_path))
        stream.write IO.read(file_path)
      end
    end

    send_data(buffer.string, :type => 'application/zip', :filename => 'pp-clipping.zip')
    copied_files.each do |f|
      f.unlink
    end
  end

  def upload_zip
    zip_file = params[:file]
    good_uploads = 0
    bad_uploads = 0

    CustomTask.begin_execute("UPLOAD_OUTFIT_PICTURES")

    Dir.mktmpdir do |dir|
      Rails.logger.info("Working with tmpdir: #{dir}")
      Zip::File.open(zip_file.path) do |zip|
        zip.each do |entry|
          filename = File.basename(entry.name)
          Rails.logger.info("Working with #{entry.name}")
          unless filename.match(/^pp-[0-9]+-/)
            Rails.logger.info("Skipping #{filename}")
            next
          end
          original_pp_id = filename.split('-')[1].to_i
          if create_outfit_picture(original_pp_id, filename, dir, zip, entry)
            good_uploads += 1
          else
            bad_uploads += 1
          end
        end
      end
    end

    CustomTask.end_execute("UPLOAD_OUTFIT_PICTURES")

    if params[:refresh_es].to_i == 1
      Modules::ElasticSearchHelper.setup_elastic_search_indexes(Product)
    end

    message = "Zip uploaded. Good: #{good_uploads} Bad: #{bad_uploads}"
    Rails.logger.info(message)
    redirect_to admin_clip_pp_without_outfit_pic_path, notice: message
  end

  def create_outfit_picture(original_pp_id, filename, dir, zip, entry)
    original_pp = ProductPicture.find_by(id: original_pp_id)
    if original_pp.blank?
      Rails.logger.error("Couldn't find PP with id #{original_pp_id}!")
      return false
    end
    filepath = File.join(dir, filename)
    zip.extract(entry, filepath)
    p = File.new(filepath, 'r')

    success = true
    ProductPicture.where(product_id: original_pp.product_id, outfit_compatible: true).each do |op|
      if !op.update_attributes(:order_index => 2)
        Rails.logger.error("Error updating the old outfit picture. Product picture ID: #{op.id}, Original product picture ID: #{original_pp_id}, Errors #{op.errors.full_messages.join(",")}")
        success = false
      end
    end
    pars = {
      color_id: original_pp.color_id,
      order_index: 1,
      product_id: original_pp.product_id,
      picture: p,
      outfit_compatible: true,
      original_product_picture_id: original_pp_id
    }
    new_pic = ProductPicture.create(pars)
    if new_pic.persisted?
      success = true
    else
      Rails.logger.error("Failed saving pp id #{original_pp_id}. #{new_pic.errors.full_messages.join(", ")}")
      success = false
    end
    p.close
    return success
  end

end