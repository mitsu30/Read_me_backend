class Api::V1::TemplatesController < ApplicationController
  def index
    @user = current_user
    templates = Template.all if @user.is_student
    templates = Template.where(only_student: false) unless @user.is_student
    render json: templates.map { |template| template_to_json(template) }
  end

  private

  def template_to_json(template)
    {
      id: template.id,
      name: template.name,
      image_path: template.image_path,
      next_path: template.next_path,
      only_student: template.only_student
    }
  end
end
