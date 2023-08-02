class ProfileAnniversaryForm
  include ActiveModel::Model

  attr_accessor :user, :answers

  TEMPLATE_ID = '4'
  QUESTION_ID_1 = '16'
  QUESTION_ID_2 = '17'
  TEMPLATE_IMAGE_PATH = 'public/images/template4.png'
  FONT_PATH='public/fonts/Yomogi.ttf'
  TEMP_IMAGE_PATH='tmp/composite_image.png'

  def save
    begin
      ActiveRecord::Base.transaction do
        profile, answer_1, answer_2, temp_image_path = build_profile_and_answers_and_image_path
        
        profile.uuid = SecureRandom.uuid
        profile.save!
        profile.image.attach(io: File.open(temp_image_path), filename: 'composite_image.png')

        File.delete(temp_image_path)

        answer_1.save!
        answer_2.save!
        
        profile
      end
    rescue => e
      errors.add(:base, e.message)
      nil
    end
  end

  def preview
    begin
      profile, answer_1, answer_2, temp_image_path = build_profile_and_answers_and_image_path
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

    composite_image = generate_image(@answers)

    temp_image_path = Rails.root.join(TEMP_IMAGE_PATH)
    composite_image.write(temp_image_path)

    [profile, answer_1, answer_2, temp_image_path]
  end

  def generate_image(answers)
    composite_image = MiniMagick::Image.open(Rails.root.join(TEMPLATE_IMAGE_PATH))
    
    composite_image.combine_options do |c|
      c.gravity 'SouthWest' 
      c.pointsize '28'
      c.font Rails.root.join(FONT_PATH)
      c.fill '#666666'
      c.annotate '+935+28', answers[:body2]

      lines = answers[:body1].split("\n")
      lines.each_with_index do |line, index|
        text_position = case lines.size
        when 1
          "0,#{287 + index * 40}"
        when 2
          "0,#{270 + index * 40}"
        when 3
          "0,#{248 + index * 40}"
        when 4
          "0,#{235 + index * 40}"
        when 5
          "0,#{215 + index * 40}"
        when 6
          "0,#{193 + index * 40}"
        end
  
        composite_image.combine_options do |c|
          c.gravity 'North'
          c.pointsize '28'
          c.font Rails.root.join(FONT_PATH)
          c.fill '#666666'
          c.draw "text #{text_position} '#{line}'"
        end
      end
    end
    
    composite_image
  end
end
