class SearchController < ApplicationController
  def index
    if params[:q].blank?
      @members = []
    else
      @members = Member.where("name like ?", "%#{params[:q]}%")
    end
  end
end
