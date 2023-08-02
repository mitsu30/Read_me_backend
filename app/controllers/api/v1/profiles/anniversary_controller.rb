class Api::V1::Profiles::AnniversaryController < Api::V1::Profiles::BaseController

  def preview
    form = ProfileAnniversaryForm.new(user: @user, answers: answers_params)

    if (encoded_image = form.preview)
      render json: { url: "data:image/jpg;base64,#{encoded_image}" }
    else
      render json: { error: form.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def create
    form = ProfileAnniversaryForm.new(user: @user, answers: answers_params)

    if (profile = form.save)
      render json: { status: 'success', message: 'Image created successfully.', url: profile.image.url, uuid: profile.uuid }
    else
      render json: { error: form.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private
  
  def answers_params
    params.require(:answers).permit(:body1, :body2)
  end
end
