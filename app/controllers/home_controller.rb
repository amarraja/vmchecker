class HomeController < ApplicationController

  def index
    @entries = Statusentry.order("id desc").paginate(:page => params[:page], :per_page => 50)
  end

  def update
    entry = Statusentry.create_update_for_postcode("nw64px")
    render :text => "ok: #{entry.id}"
  end
end
