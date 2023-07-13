class Api::V1::Profiles::SchoolController < Api::V1::Profiles::BaseController
  
  def preview
    form = ProfileSchoolForm.new(user: @user, answers: answers_params)

    if (encoded_image = form.preview)
      render json: { url: "data:image/jpg;base64,#{encoded_image}" }
    else
      render json: { error: form.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end


  def create
    form = ProfileSchoolForm.new(user: @user, answers: answers_params)

    if (profile = form.save)
      render json: { status: 'success', message: 'Image created successfully.', url: profile.image.url, uuid: profile.uuid }
    else
      render json: { error: form.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private
  
  def answers_params
    params.require(:answers).permit(:body1, :body2, :body3, :body4, :body5)
  end
end
