class ThemesController < ApplicationController
  def update
    Theme.update(cookies, flavour: params[:flavour], accent: params[:accent])
    redirect_back_or_to root_path
  end
end
