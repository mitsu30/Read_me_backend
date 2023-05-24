class Api::V1::ImageTextsController < ApplicationController
  require 'mini_magick'

  def create
    buybug
    image_text = ImageText.new(answer1: params[:answer1], answer2: params[:answer2], answer3: params[:answer3])
    render json: { errors: image_text.errors.full_messages }, status: :unprocessable_entity
      
    # # MiniMagickを使って画像を読み込みます。
    # image = MiniMagick::Image.open('path_to_your_base_image.jpg')

    # # 画像にテキストを追加します。
    # image.combine_options do |c|
    #   c.gravity 'Center'
    #   c.pointsize '32'
    #   c.draw "text 0,0 '#{image_text.text}'"
    #   c.fill 'white'
    # end

    # # テキストが追加された画像を一時的なファイルに保存します。
    # temp_image_path = Rails.root.join('tmp', 'temp_image.jpg')
    # image.write(temp_image_path)

    # # 画像をActiveStorageにアップロードします。
    # image_text.image.attach(io: File.open(temp_image_path), filename: 'temp_image.jpg')

    # # 一時ファイルを削除します。
    # File.delete(temp_image_path)

    # if image_text.save
    #   render json: { url: url_for(image_text.image) }
    # else
    #   render json: { errors: image_text.errors.full_messages }, status: :unprocessable_entity
    # end
  end
end
