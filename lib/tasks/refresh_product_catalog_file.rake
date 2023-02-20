namespace :product_catalog do

  desc "Refreshes product catalog files which are used currently for facebook product catalog upload."
  task :refresh_file => "setup:fashionlime" do
    include Modules::ClientUrlLib

    products = Product.visible.collection_display.includes(:trade_mark)


    begin 
      last_night = Time.zone.now - 24.hours
      products.each do |p|
        if p.product_pictures.size >= 2
          p1 = p.product_pictures.sort_by { |pp| pp.order_index }[0]
          p2 = p.product_pictures.sort_by { |pp| pp.order_index }[1]
          # Generate picture if there is no picture or product pictures has changed
          if !p.catalog_picture.present? || p1.updated_at >= last_night || p2.updated_at >= last_night
            generate_landscape_catalog_picture(p, p1, p2)
          end
        end

        if p.product_pictures.size >= 1
          pic = p.product_pictures.sort_by { |pp| pp.order_index }[0]
          if !p.catalog_square_picture.present? || pic.updated_at >= last_night
            generate_square_catalog_picture(p, pic)
          end
        end
      end

      ########## Landscape pictures
      import_file = "public/system/product_catalog/import_file.xml"
      generate_import_file(import_file, products, Proc.new {|product| product.catalog_picture.present? ? "https://fashionlime.bg#{product.catalog_picture.url(:original, :timestamp => false)}" : nil })

      ######### Square pictures
      import_file = "public/system/product_catalog/import_file_square_pics.xml"
      generate_import_file(import_file, products, Proc.new {|product| product.catalog_square_picture.present? ? "https://fashionlime.bg#{product.catalog_square_picture.url(:original, :timestamp => false)}" : nil })
    rescue StandardError => e
      Rails.logger.error("Error while refreshing product catalog. Error is #{e}. Backtrace: #{e.backtrace.join('\n')}")
    end    
  
    Rails.logger.info("Product catalog files refreshed successfully.")
  end

  def generate_import_file(import_file, products, catalog_picture_url_func)
    # Copy template
    FileUtils.cp("public/product_catalog/template.xml", "public/system/product_catalog")
    # Deletes previous import
    if File.exist?(import_file)
      FileUtils.rm(import_file)
    end
    # Renames the template file
    File.rename("public/system/product_catalog/template.xml", import_file)
    
    doc = File.open(import_file) { |f| Nokogiri::XML(f) }
    description = doc.xpath("//description")[0]

    products.each do |p|
      image_link = catalog_picture_url_func.call(p)
      if image_link.present?
        description.add_next_sibling(format_product_item(p, image_link))
      end
    end
    File.write(import_file, doc.to_xml)
  end

  def format_product_item(p, image_link)
    # TODO provide more accurate product category
    # https://support.google.com/merchants/answer/6324436?hl=en
    full_name = "#{p.name} от #{p.merchant.name}"
    is_available = p.normal? && p.available?
    "<item>
      <g:id>#{p.id}</g:id>
      <g:title>#{full_name}</g:title>
      <g:description>#{p.description.present? ? p.description : full_name}</g:description>
      <g:link>#{product_url(p)}</g:link>
      <g:image_link>#{image_link}</g:image_link>
      <g:brand>#{p.trade_mark.try(:name) || p.merchant.name}</g:brand>
      <g:condition>new</g:condition>
      <g:availability>#{is_available ? "in stock" : "out of stock"}</g:availability>
      <g:price>#{p.catalog_price} BGN</g:price>
      <g:google_product_category>166</g:google_product_category>
    </item>"
  end

  def generate_landscape_catalog_picture(product, picture_1, picture_2)
    Rails.logger.info("Generating landscape catalog picture for product with ID:#{product.id}")
    empty_image = Magick::Image.read("public/product_catalog/image_empty_filler.png").first
    image_list = Magick::ImageList.new
    # Empty white pixels to the left to match product catalog desired size
    image_list.push(empty_image) 
    image_list.push(Magick::Image.read(picture_1.picture.path(:original)).first)
    image_list.push(Magick::Image.read(picture_2.picture.path(:original)).first)
    # Empty white pixels to the right to match product catalog desired size
    image_list.push(empty_image) 
    temp_file = Tempfile.new(['test','.png'])
    image_list.append(false).write(temp_file.path)
    product.update_attributes(:catalog_picture => temp_file)
    temp_file.close
    # Deletes the temp file
    temp_file.unlink   
  end

  def generate_square_catalog_picture(product, product_picture)
    Rails.logger.info("Generating square catalog picture for product with ID:#{product.id}")
    file = File.open(product_picture.picture.path(:original))
    product.update_attributes(:catalog_square_picture => file)
    file.close
  end

end
