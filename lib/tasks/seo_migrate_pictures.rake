require 'shell'

namespace :seo do
  desc "Migrate the pictures from the default paperclip format to SEO optimized format.
        Fix the outfit product pictures url's in serialized json as well."
  task :migrate_pictures => "setup:fashionlime" do
    pwd = ENV['PWD']
    if !pwd.ends_with?('FashionLime')
      raise 'The rake task should be called from the FashionLime home dir.'
    end

    ProductPicture.all.each do |pp|
      Outfit.all.each do |o|
        if (o.serialized_json.include?("/product_pictures/#{pp.id}/"))
          o.serialized_json = o.serialized_json.gsub("/#{pp.id}/pictures/medium.jpg", "/#{pp.id}/pictures/medium/#{pp.picture_file_name}")
          o.serialized_json = o.serialized_json.gsub("/#{pp.id}/pictures/medium.png", "/#{pp.id}/pictures/medium/#{pp.picture_file_name}")
          o.save
        end
      end
    end

    shell = Shell.new
    directories = ['medium', 'original', 'thumb']
    ProductPicture.all.each do |pp|
      shell.pushd 'public/system/product_pictures/' + pp.id.to_s + '/pictures/'
      directories.each do |dir_name|
        unless shell.exists?(dir_name)
          shell.mkdir dir_name
        else
          Rails.logger.info "dir already here!"
          Rails.logger.info shell.pwd
        end
        ['png', 'jpg'].each do |suff|
          file = dir_name + '.' + suff
          if shell.exists? file
            dest_file = dir_name + '/' + pp.picture_file_name
            Rails.logger.info 'moved to ' + shell.pwd.to_s + '/' + dest_file
            shell.rename(file, dest_file)
          else
            Rails.logger.info 'file not found!'
            Rails.logger.info shell.pwd
          end
        end
      end
      shell.popd
     end

    Outfit.all.each do |o|
      shell.pushd 'public/system/outfits/' + o.id.to_s + '/pictures/'
      directories.each do |dir_name|
        unless shell.exists?(dir_name)
          shell.mkdir dir_name
        else
          Rails.logger.info "dir already here!"
          Rails.logger.info shell.pwd
        end
        ['png', 'jpg'].each do |suff|
          file = dir_name + '.' + suff
          if shell.exists? file
            dest_file = dir_name + '/' + o.picture_file_name
            Rails.logger.info 'moved to ' + shell.pwd.to_s + '/' + dest_file
            shell.rename(file, dest_file)
          else
            Rails.logger.info 'file not found!'
            Rails.logger.info shell.pwd
          end
        end
      end
      shell.popd
    end

    Merchant.all.each do |m|
      if m.logo_file_name.blank?
        next
      end
      shell.pushd 'public/system/merchants/' + m.id.to_s + '/logos/'
      directories.each do |dir_name|
        unless shell.exists?(dir_name)
          shell.mkdir dir_name
        else
          Rails.logger.info "dir already here!"
          Rails.logger.info shell.pwd
        end
        ['png', 'jpg', 'jpeg'].each do |suff|
          file = dir_name + '.' + suff
          if shell.exists? file
            dest_file = dir_name + '/' + m.logo_file_name
            Rails.logger.info 'moved to ' + shell.pwd.to_s + '/' + dest_file
            shell.rename(file, dest_file)
          else
            Rails.logger.info 'file not found!'
            Rails.logger.info shell.pwd
          end
        end
      end
      shell.popd
    end

    directories = ['original', 'thumb']
    User.all.each do |u|
      if u.avatar_file_name.blank?
        next
      end
      shell.pushd 'public/system/users/' + u.id.to_s + '/avatars/'
      directories.each do |dir_name|
        unless shell.exists?(dir_name)
          shell.mkdir dir_name
        else
          Rails.logger.info "dir already here!"
          Rails.logger.info shell.pwd
        end
        ['png', 'jpg'].each do |suff|
          file = dir_name + '.' + suff
          if shell.exists? file
            dest_file = dir_name + '/' + u.avatar_file_name
            Rails.logger.info 'moved to ' + shell.pwd.to_s + '/' + dest_file
            shell.rename(file, dest_file)
          else
            Rails.logger.info 'file not found!'
            Rails.logger.info shell.pwd
          end
        end
      end
      shell.popd
    end

    directories = ['original']
    ProductCollection.all.each do |c|
      if c.picture_file_name.blank?
        next
      end
      shell.pushd 'public/system/product_collections/' + c.id.to_s + '/pictures/'
      directories.each do |dir_name|
        unless shell.exists?(dir_name)
          shell.mkdir dir_name
        else
          Rails.logger.info "dir already here!"
          Rails.logger.info shell.pwd
        end
        ['png', 'jpg'].each do |suff|
          file = dir_name + '.' + suff
          if shell.exists? file
            dest_file = dir_name + '/' + c.picture_file_name
            Rails.logger.info 'moved to ' + shell.pwd.to_s + '/' + dest_file
            shell.rename(file, dest_file)
          else
            Rails.logger.info 'file not found!'
            Rails.logger.info shell.pwd
          end
        end
      end
      shell.popd
    end

  end
end
