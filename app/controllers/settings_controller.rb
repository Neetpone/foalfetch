class SettingsController < ApplicationController
  def show
    @settings = {
      theme: cookies[:theme]
    }
  end

  def update
    cookies.permanent[:theme] = params[:theme] if params[:theme]
  end
end