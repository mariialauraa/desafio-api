module Admin::V1
  class HomeController < ApplicationController
    before_action :authorize

    def index
      render json: {message: 'Uhul!'}
    end
  end
end