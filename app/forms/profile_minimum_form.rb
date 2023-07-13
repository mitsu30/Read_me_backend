class ProfileMinimumForm
  include ActiveModel::Model

  attr_accessor :user, :answers

  TEMPLATE_ID = '1'
  QUESTION_ID_1 = '1'
  QUESTION_ID_2 = '2'
  QUESTION_ID_3 = '3'
  TEMPLATE_IMAGE_PATH = 'public/images/template1.png'
  FONT_PATH='public/fonts/Yomogi.ttf'
  TEMP_IMAGE_PATH='tmp/composite_image.png'

  def save
    begin
      ActiveRecord::Base.transaction do
        profile, answer_1, answer_2, answer_3, temp_image_path = build_profile_and_answers_and_image_path
        
        profile.uuid = SecureRandom.uuid
        profile.save!
        profile.image.attach(io: File.open(temp_image_path), filename: 'composite_image.png')

        File.delete(temp_image_path)

        answer_1.save!
        answer_2.save!
        answer_3.save!
        
        profile
      end
    rescue => e
      errors.add(:base, e.message)
      nil
    end
  end

  def preview
    begin
      profile, answer_1, answer_2, answer_3, temp_image_path = build_profile_and_answers_and_image_path
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

    composite_image = generate_image(@answers)

    temp_image_path = Rails.root.join(TEMP_IMAGE_PATH)
    composite_image.write(temp_image_path)

    [profile, answer_1, answer_2, answer_3, temp_image_path]
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
