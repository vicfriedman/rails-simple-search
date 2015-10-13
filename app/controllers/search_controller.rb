class SearchController < ApplicationController

  def index
    @results= Search.for(params[:keyword])
    if @results.length == 1
      redirect_to @results.first
    else
      @results
    end
  end


end
