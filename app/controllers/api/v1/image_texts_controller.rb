module Api
  module V1
    class App::V1::ImageTextsController < ApplicationController
      def create
        image_text = ImageText.new(answer1: params[:answer1], answer2: params[:answer2], answer3: params[:answer3])
      end
    end
  end
end 
