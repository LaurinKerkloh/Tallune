class ThemesController < ApplicationController
  def update
    Theme.update(cookies, **params.permit(:flavour, :accent).to_h.symbolize_keys)
    redirect_back_or_to root_path
  end
end
