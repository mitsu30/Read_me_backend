class Api::V1::ProfilesController < ApplicationController
  require 'mini_magick'
  require 'base64' 
  

  def preview
    user = current_user

    profile = current_user.profiles.build(template_id: 1)

    answers = params[:answers]
    answer_1 = profile.answers.build(question_id: 1, body: params[:answers][:body1])
    answer_2 = profile.answers.build(question_id: 2, body: params[:answers][:body2])
    answer_3 = profile.answers.build(question_id: 3, body: params[:answers][:body3])
    
    composite_image = generate_image(answers)

    temp_image_path = Rails.root.join('tmp', 'composite_image.png')
    composite_image.write(temp_image_path)

    encoded_image = Base64.encode64(File.open(temp_image_path).read)
    File.delete(temp_image_path)

    render json: { url: "data:image/jpg;base64,#{encoded_image}" } 
  end


  def create
    user = current_user
    ActiveRecord::Base.transaction do
      profile = current_user.profiles.build(template_id: 1)
      
      answers = params[:answers]
      answer_1 = profile.answers.build(question_id: 1, body: params[:answers][:body1])
      answer_2 = profile.answers.build(question_id: 2, body: params[:answers][:body2])
      answer_3 = profile.answers.build(question_id: 3, body: params[:answers][:body3])
      
      composite_image = generate_image(answers)

      temp_image_path = Rails.root.join('tmp', 'composite_image.png')
      composite_image.write(temp_image_path)

      profile.save!
      profile.image.attach(io: File.open(temp_image_path), filename: 'composite_image.png')

      File.delete(temp_image_path)

      answer_1.save!
      answer_2.save!
      answer_3.save!
    end
  end
  
  private

  def image_text_params
    params.require(:answer).permit(:body)
  end

  def generate_image(answers)
    # MiniMagickを使って画像を読み込む。
    composite_image = MiniMagick::Image.open(Rails.root.join('public', 'images', 'template1.png'))

    # 画像にテキストを追加する。
    composite_image.combine_options do |c|
      c.gravity 'North'
      c.pointsize '40'
      c.font Rails.root.join('public', 'fonts', 'Yomogi.ttf') 
      c.fill '#666666'
      c.annotate '-268+207', answers[:body1]
      c.annotate '+271+207', answers[:body2]

      lines = answers[:body3].split("\n")
      lines.each_with_index do |line, index|
        text_position = case lines.size
        when 1
          "0,#{418 + index * 40}"
        when 2
          "0,#{396 + index * 40}"
        when 3
          "0,#{380 + index * 40}"
        end
  
        composite_image.combine_options do |c|
          c.gravity 'North'
          c.pointsize '40'
          c.font Rails.root.join('public', 'fonts', 'Yomogi.ttf')
          c.fill '#666666'
          c.draw "text #{text_position} '#{line}'"
        end
      end
    end
    
    composite_image
  end
end
