class SearchController < ApplicationController
  def index
    if params[:q].blank?
      @members = []
    else
      @members = Member.where("lower(name) like ?", "%#{params[:q].downcase}%")
    end
  end
end
