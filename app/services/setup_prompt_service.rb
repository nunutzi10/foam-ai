# frozen_string_literal: true

# [SetupPromptService]
class SetupPromptService < ApplicationService
  # includes
  include Openaiable

  # Calls the build_message! method to construct the message content
  # This method serves as an entry point to trigger the message building process
  # @return nil
  def call!
    build_message!
  end

  private

  # Downloads the content of the [file] attribute and transcribes the image
  #   content via the [RTesseract] OCR library
  # Updates the [text] attribute with the result
  # @return nil
  def transcribe_image_content!
    tmp_dir = 'tmp'
    FileUtils.mkdir_p(tmp_dir)
    unique_filename = "imagen_#{Time.now.to_i}.jpg"
    file_path = File.join(tmp_dir, unique_filename)
    File.binwrite(file_path, URI.open(media_url).read)
    image = RTesseract.new(file_path)
    self.text = image.to_s
    FileUtils.rm_f(file_path)
  end

  # Downloads the content of the [file] attribute and and transcribes the audio
  #   content via the [Openai] whisper API
  # Updates the [content] attribute with the result
  # @return nil
  def transcribe_audio_content!
    tmp_dir = 'tmp'
    FileUtils.mkdir_p(tmp_dir)
    unique_filename = "audio_#{Time.now.to_i}.ogg"
    file_path = File.join(tmp_dir, unique_filename)
    File.binwrite(file_path, URI.open(media_url).read)
    response = openai_client.audio.transcribe(
      parameters: {
        model: 'whisper-1',
        file: File.open(file_path, 'rb')
      }
    )
    self.text = response['text']
    FileUtils.rm_f(file_path)
  end

  # Builds the message content based on
  # the [message_content_type] attribute
  # If the content type is TEXT, it sets the message body directly
  # If the content type is IMAGE,
  # it transcribes the image content and appends the result to the message body
  # If the content type is AUDIO,
  # it transcribes the audio content and appends the result to the message body
  # @return nil
  def build_message!
    case message_content_type
    when Message::ContentType::TEXT
      message_body
    when Message::ContentType::IMAGE
      transcribe_image_content!
      message_body << " #{text}"
    when Message::ContentType::AUDIO
      transcribe_audio_content!
      self.message_body = text
    end
  end

  attr_accessor :message_content_type, :message_body, :media_url, :text,
                :tenant

  # Initializes a new instance of the class with the given arguments
  # This method dynamically sets instance variables based on the provided hash
  # @param [Hash] args A hash where keys are attribute
  # names and values are the values to be assigned
  def initialize(args)
    args.each { |key, val| send "#{key}=", val }
  end
end
