class Api::V1::ImageTextsController < ApplicationController
  require 'mini_magick'
  require 'base64' 

  def preview
    image_text = ImageText.new(answer1: params[:image_text][:answer1], answer2: params[:image_text][:answer2], answer3: params[:image_text][:answer3])
    image = generate_image(image_text)

    temp_image_path = Rails.root.join('tmp', 'temp_image.jpg')
    image.write(temp_image_path)

    encoded_image = Base64.encode64(File.open(temp_image_path).read)
    File.delete(temp_image_path)

    render json: { url: "data:image/jpg;base64,#{encoded_image}" } 
  end

  def create
    image_text = ImageText.new(answer1: params[:image_text][:answer1], answer2: params[:image_text][:answer2], answer3: params[:image_text][:answer3])
  
    # まずは ImageText オブジェクトを保存
    if image_text.save
      begin
        # 例外が発生する可能性のあるコードを begin-end ブロック内に配置
        image = generate_image(image_text)
        temp_image_path = Rails.root.join('tmp', 'temp_image.jpg')
        image.write(temp_image_path)
        
        image_text.image.attach(io: File.open(temp_image_path), filename: 'temp_image.jpg')
        File.delete(temp_image_path)
        
        render json: { url: url_for(image_text.image), id: image_text.id }
      rescue => e
        # 何か問題が発生した場合は、そのエラーを捕捉し、エラーメッセージを返す
        render json: { errors: [e.message] }, status: :internal_server_error
      end
    else
      render json: { errors: image_text.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    image_text = ImageText.find(params[:id])
    if image_text
      render json: { url: url_for(image_text.image) }
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end

  private

  def generate_image(image_text)
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

    image
  end
end
