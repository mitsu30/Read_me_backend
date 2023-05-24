class Api::V1::ImageTextsController < ApplicationController
  require 'mini_magick'

  def create
    image_text = ImageText.new(answer1: params[:answer1], answer2: params[:answer2], answer3: params[:answer3])
      
    # MiniMagickを使って画像を読み込む。
    image = MiniMagick::Image.open(Rails.root.join('public', 'images', 'template1.png'))

    # 画像にテキストを追加する。
    image.combine_options do |c|
      c.gravity 'North'
      c.pointsize '32'
      c.font Rails.root.join('public', 'fonts', 'Yomogi.ttf')  
      c.draw "text 0,180 '#{image_text.answer1}'"
      c.draw "text 0,325 '#{image_text.answer2}'"
      c.draw "text 0,475 '#{image_text.answer3}'"
      c.fill 'black'
    end

    # テキストが追加された画像を一時的なファイルに保存する。
    temp_image_path = Rails.root.join('tmp', 'temp_image.jpg')
    image.write(temp_image_path)

    # 画像をActiveStorageにアップロードします。
    image_text.image.attach(io: File.open(temp_image_path), filename: 'temp_image.jpg')

    # 一時ファイルを削除する。
    File.delete(temp_image_path)

    if image_text.save
      render json: { url: url_for(image_text.image) }
    else
      render json: { errors: image_text.errors.full_messages }, status: :unprocessable_entity
    end
  end
end

