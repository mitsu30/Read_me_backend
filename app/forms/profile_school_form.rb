class ProfileSchoolForm
  include ActiveModel::Model
  
  attr_accessor :user, :answers

  TEMPLATE_ID = '3'
  QUESTION_ID_1 = '11'
  QUESTION_ID_2 = '12'
  QUESTION_ID_3 = '13'
  QUESTION_ID_4 = '14'
  QUESTION_ID_5 = '15'
  TEMPLATE_IMAGE_PATH = 'public/images/template3.png'
  FONT_PATH='public/fonts/Yomogi.ttf'
  TEMP_IMAGE_PATH='tmp/composite_image.png'

  def save
    begin
      ActiveRecord::Base.transaction do
        profile, answer_1, answer_2, answer_3, answer_4, answer_5, temp_image_path = build_profile_and_answers_and_image_path

        profile.uuid = SecureRandom.uuid
        profile.save!
        profile.image.attach(io: File.open(temp_image_path), filename: 'composite_image.png')

        File.delete(temp_image_path)

        answer_1.save!
        answer_2.save!
        answer_3.save!
        answer_4.save!
        answer_5.save!

        profile
      end
    rescue => e
      errors.add(:base, e.message)
      nil
    end
  end

  def preview
    begin
      profile, answer_1, answer_2, answer_3, answer_4, answer_5, temp_image_path = build_profile_and_answers_and_image_path
      encoded_image = Base64.encode64(File.open(temp_image_path).read)
      File.delete(temp_image_path)

      encoded_image
    rescue => e
      errors.add(:base, e.message)
      nil
    end
  end

  private

  def build_profile_and_answers_and_image_path
    profile = @user.profiles.build(template_id: TEMPLATE_ID)
    
    answer_1 = profile.answers.build(question_id: QUESTION_ID_1, body: @answers[:body1])
    answer_2 = profile.answers.build(question_id: QUESTION_ID_2, body: @answers[:body2])
    answer_3 = profile.answers.build(question_id: QUESTION_ID_3, body: @answers[:body3])
    answer_4 = profile.answers.build(question_id: QUESTION_ID_4, body: @answers[:body4])
    answer_5 = profile.answers.build(question_id: QUESTION_ID_5, body: @answers[:body5])
    
    composite_image = generate_image(@answers, @user)

    temp_image_path = Rails.root.join(TEMP_IMAGE_PATH)
    composite_image.write(temp_image_path)
    [profile, answer_1, answer_2, answer_3, answer_4, answer_5, temp_image_path]
  end

  def generate_image(answers, user)
    composite_image = MiniMagick::Image.open(Rails.root.join(TEMPLATE_IMAGE_PATH))
    
    avatar_filename = SecureRandom.hex
    avatar_path = Rails.root.join('tmp', "#{avatar_filename}.png")

    if user.avatar.attached?
      File.open(avatar_path, 'wb') do |file|
        file.write(user.avatar.download)
      end
    else
      FileUtils.cp(Rails.root.join('public/images/default_avatar.png'), avatar_path)
    end

    cropped_filename = SecureRandom.hex
    cropped_and_resized_avatar_path = Rails.root.join('tmp', "#{cropped_filename}.png")
    avatar_image = MiniMagick::Image.open(avatar_path)
    avatar_image.combine_options do |c|
      c.gravity "Center"
      shortest_side = [avatar_image.width, avatar_image.height].min
      c.crop "#{shortest_side}x#{shortest_side}+0+0"
      c.resize "200x200"
    end
    avatar_image.write(cropped_and_resized_avatar_path)
    
    output_filename = SecureRandom.hex
    output_path = Rails.root.join('tmp', "#{output_filename}.png")
    user_image = MiniMagick::Image.open(cropped_and_resized_avatar_path)
    MiniMagick::Tool::Convert.new do |img|
      img.size "200x200"
      img << 'xc:transparent'
      img.fill cropped_and_resized_avatar_path
      img.draw "translate 100, 100 circle 0,0 100,0"
      img.trim
      img << output_path
    end
  
    composite_image = composite_image.composite(MiniMagick::Image.open(output_path)) do |c|
      c.compose 'Over'    
      c.geometry '+890+115' 
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
    
    File.delete(avatar_path)
    File.delete(cropped_and_resized_avatar_path)
    File.delete(output_path)
    
    composite_image
  end
end
