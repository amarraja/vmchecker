class HomeController < ApplicationController

  def index
    @entries = Statusentry.order("id desc").paginate(:page => params[:page], :per_page => 50)
  end

  def view_response
    @entry = Statusentry.find(params[:id])
  end

  def raw_response
    @entry = Statusentry.find(params[:id])
    replaced_body = @entry.raw_body.gsub("/includes/styles", "https://my.virginmedia.com/includes/styles")
    respond_to do |f|
      f.html { render :text => replaced_body }
    end
  end

  def update
    entry = Statusentry.create_update_for_postcode("nw64px")
    render :text => "ok: #{entry.id}"
  end
end
