class Api::V1::ProfilesController < ApplicationController
  require 'mini_magick'
  require 'base64' 

  TEMPLATE_ID = ENV['TEMPLATE1_ID']
  QUESTION_ID_1 = ENV['QUESTION_ID_1']
  QUESTION_ID_2 = ENV['QUESTION_ID_2']
  QUESTION_ID_3 = ENV['QUESTION_ID_3']
  TEMPLATE_IMAGE_PATH = ENV['TEMPLATE1_IMAGE_PATH']
  FONT_PATH = ENV['FONT_PATH']
  TEMP_IMAGE_PATH = ENV['TEMP_IMAGE_PATH']

  def preview
    begin
      user, profile, answer_1, answer_2, answer_3, temp_image_path = build_profile_and_answers_and_image_path

      encoded_image = Base64.encode64(File.open(temp_image_path).read)
      File.delete(temp_image_path)

      render json: { url: "data:image/jpg;base64,#{encoded_image}" } 
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        user, profile, answer_1, answer_2, answer_3, temp_image_path = build_profile_and_answers_and_image_path
        
        profile.save!
        profile.image.attach(io: File.open(temp_image_path), filename: 'composite_image.png')

        File.delete(temp_image_path)

        answer_1.save!
        answer_2.save!
        answer_3.save!
      end
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
  
  private
  
  def build_profile_and_answers_and_image_path
    user = current_user
    profile = current_user.profiles.build(template_id: TEMPLATE_ID)
    
    answers = answers_params
    answer_1 = profile.answers.build(question_id: QUESTION_ID_1, body: answers[:body1])
    answer_2 = profile.answers.build(question_id: QUESTION_ID_2, body: answers[:body2])
    answer_3 = profile.answers.build(question_id: QUESTION_ID_3, body: answers[:body3])
    
    composite_image = generate_image(answers)

    temp_image_path = Rails.root.join(TEMP_IMAGE_PATH)
    composite_image.write(temp_image_path)

    [user, profile, answer_1, answer_2, answer_3, temp_image_path]
  end

  def answers_params
    params.require(:answers).permit(:body1, :body2, :body3)
  end

  def generate_image(answers)
    composite_image = MiniMagick::Image.open(Rails.root.join(TEMPLATE_IMAGE_PATH))
    
    composite_image.combine_options do |c|
      c.gravity 'North'
      c.pointsize '40'
      c.font Rails.root.join(FONT_PATH)
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
          c.font Rails.root.join(FONT_PATH)
          c.fill '#666666'
          c.draw "text #{text_position} '#{line}'"
        end
      end
    end
    
    composite_image
  end
end
