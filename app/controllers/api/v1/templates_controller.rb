class Api::V1::TemplatesController < ApplicationController
  def index
    templates = Template.all
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
