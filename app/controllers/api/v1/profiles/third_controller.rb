class Api::V1::Profiles::ThirdController < ApplicationController
  require 'mini_magick'
  require 'base64' 

  TEMPLATE_ID = ENV['TEMPLATE3_ID']
  QUESTION_ID_1 = ENV['TEMPLATE3_QUESTION_ID_1']
  QUESTION_ID_2 = ENV['TEMPLATE3_QUESTION_ID_2']
  QUESTION_ID_3 = ENV['TEMPLATE3_QUESTION_ID_3']
  QUESTION_ID_4 = ENV['TEMPLATE3_QUESTION_ID_4']
  QUESTION_ID_5 = ENV['TEMPLATE3_QUESTION_ID_5']
  TEMPLATE_IMAGE_PATH = ENV['TEMPLATE3_IMAGE_PATH']
  FONT_PATH = ENV['FONT_PATH']
  TEMP_IMAGE_PATH = ENV['TEMP_IMAGE_PATH']

  def preview
    begin
      user, profile, answer_1, answer_2, answer_3, answer_4, answer_5, temp_image_path = build_profile_and_answers_and_image_path
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
        user, @profile, answer_1, answer_2, answer_3, temp_image_path = build_profile_and_answers_and_image_path
        
        @profile.uuid = SecureRandom.uuid
        @profile.save!
        @profile.image.attach(io: File.open(temp_image_path), filename: 'composite_image.png')

        File.delete(temp_image_path)

        answer_1.save!
        answer_2.save!
        answer_3.save!
      end
      render json: { status: 'success', message: 'Image created successfully.', url: @profile.image.url, uuid: @profile.uuid }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def show
    user = current_user
    profile = user.profiles.find_by(uuid: params[:id])
    if profile
      render json: { image_url: profile.image.url, privacy: profile.privacy }
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end

  def destroy
    begin
      user = current_user
      profile = user.profiles.find_by(uuid: params[:id])
      profile.destroy!
      render json: { status: 'success', message: 'Profile destroyed successfully.'}
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
  
  private
  
  def build_profile_and_answers_and_image_path
    user = current_user
    profile = user.profiles.build(template_id: TEMPLATE_ID)
    
    answers = answers_params
    answer_1 = profile.answers.build(question_id: QUESTION_ID_1, body: answers[:body1])
    answer_2 = profile.answers.build(question_id: QUESTION_ID_2, body: answers[:body2])
    answer_3 = profile.answers.build(question_id: QUESTION_ID_3, body: answers[:body3])
    answer_4 = profile.answers.build(question_id: QUESTION_ID_4, body: answers[:body4])
    answer_5 = profile.answers.build(question_id: QUESTION_ID_5, body: answers[:body5])
    
    composite_image = generate_image(answers, user)

    temp_image_path = Rails.root.join(TEMP_IMAGE_PATH)
    composite_image.write(temp_image_path)
    [user, profile, answer_1, answer_2, answer_3, answer_4, answer_5, temp_image_path]
  end

  def answers_params
    params.require(:answers).permit(:body1, :body2, :body3, :body4, :body5)
  end

  def generate_image(answers, user)
    composite_image = MiniMagick::Image.open(Rails.root.join(TEMPLATE_IMAGE_PATH))
  
    # Generate temporary avatar file
    avatar_path = Rails.root.join('tmp', 'avatar.png')
    File.open(avatar_path, 'wb') do |file|
      file.write(user.avatar.download)
    end
  
    # Crop the avatar image to a square and resize it to 200x200
    cropped_and_resized_avatar_path = Rails.root.join('tmp', 'cropped_and_resized_avatar.png')
    avatar_image = MiniMagick::Image.open(avatar_path)
    avatar_image.combine_options do |c|
      c.gravity "Center"
      shortest_side = [avatar_image.width, avatar_image.height].min
      c.crop "#{shortest_side}x#{shortest_side}+0+0"
      c.resize "200x200"
    end
    avatar_image.write(cropped_and_resized_avatar_path)
  
    # Now generate circular avatar
    output_path = Rails.root.join('tmp', 'output.png')
    user_image = MiniMagick::Image.open(cropped_and_resized_avatar_path)
    MiniMagick::Tool::Convert.new do |img|
      img.size "200x200"
      img << 'xc:transparent'
      img.fill cropped_and_resized_avatar_path
      img.draw "translate 100, 100 circle 0,0 100,0"
      img.trim
      img << output_path
    end
    
    # Here, replace the original avatar_image with the circular avatar in the composite image
    composite_image = composite_image.composite(MiniMagick::Image.open(output_path)) do |c|
      c.compose 'Over'    # OverCompositeOp
      c.geometry '+890+115' # place at (10, 10)
    end
    
    composite_image.combine_options do |c|
      c.gravity 'North'
      c.pointsize '30'
      c.font Rails.root.join(FONT_PATH)
      c.fill '#666666'
      c.annotate '-268+156', answers[:body1]
      c.annotate '-174+216', answers[:body2]
      c.annotate '-100+280', answers[:body3]
      c.annotate '-156+414', answers[:body4]
      c.annotate '-278+494', answers[:body5]
      c.annotate '+105+156', user.membered_groups.find_by(community_id: 1)&.name
    end
    
    composite_image
  end
end
