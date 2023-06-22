class Api::V1::TemplatesController < ApplicationController
  def index
    templates = Template.all
  end
end
