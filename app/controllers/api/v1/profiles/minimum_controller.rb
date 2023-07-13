class Api::V1::Profiles::MinimumController < Api::V1::Profiles::BaseController
  def preview
    form = ProfileMinimumForm.new(user: @user, answers: answers_params)

    if (encoded_image = form.preview)
      render json: { url: "data:image/jpg;base64,#{encoded_image}" }
    else
      render json: { error: form.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def create
    form = ProfileMinimumForm.new(user: @user, answers: answers_params)

    if (profile = form.save)
      render json: { status: 'success', message: 'Image created successfully.', url: profile.image.url, uuid: profile.uuid }
    else
      render json: { error: form.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private

  def answers_params
    params.require(:answers).permit(:body1, :body2, :body3)
  end
end

