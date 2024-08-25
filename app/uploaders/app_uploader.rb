# frozen_string_literal: true

# [AppUploader] definition
class AppUploader < CarrierWave::Uploader::Base
  # Choose what kind of storage to use for this uploader:
  storage :fog

  # set the maximum size of a file upload
  def size_range
    (1.byte)..(5.megabytes)
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    @store_dir ||= lambda do
      parts = [Rails.env, model.class.to_s.underscore, mounted_as, model.id]
      parts.join('/')
    end.call
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_allowlist
    %i[png jpeg jpg pdf mp3 mpga mp4]
  end

  # Override tmp dir for storage before upload
  # @return nil
  def cache_dir
    Rails.root.join('tmp/uploads')
  end

  # Override the filename for the uploaded files
  # def filename
  #   return if original_filename.blank?
  #   @filename = "#{SecureRandom.uuid}.#{file.extension}"
  # end
  def filename
    return nil if original_filename.blank?

    return @filename unless original_filename == @filename

    @filename = "#{SecureRandom.uuid}.#{file.extension}"
    @filename
  end
end
