class MoviesController < ApplicationController
  
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def index 
    @all_ratings = ['G','PG','PG-13','R','NC-17']
    @ratings =  {"G" => "1", "PG" => "1", "PG-13" => "1", "R" => "1", "NC-17" => "1"}
    if params[:ratings] == nil and params[:sort_by] == nil
      session[:ratings] = @ratings
      session[:sort_by] = nil
    end
    if session.has_key?(:ratings) && params.has_key?(:sort_by)
      session[:sort_by] = params[:sort_by]
      @ratings = session[:ratings]
      @movies = Movie.where(rating: @ratings.keys).order(params[:sort_by])
    elsif
      session.has_key?(:sort_by) && params.has_key?(:ratings)
      @ratings = params[:ratings]
      session[:ratings] = @ratings
      @movies = Movie.where(rating: @ratings.keys).order(session[:sort_by])
    elsif
      session[:ratings] == nil && params.has_key?(:sort_by)
      session[:sort_by] = params[:sort_by]
      @movies = Movie.order(params[:sort_by])
    elsif
      session[:sort_by] == nil && params.has_key?(:ratings)
      @ratings = params[:ratings]
      @movies = Movie.where(rating: @ratings.keys)
      session[:ratings] = @ratings
    else
      @movies = Movie.all
    end
  end

  def new
    # default: render 'new' template
  end
  
  def updated
    @movie = Movie.find_by_title(params[:movieold][:title])
    if params[:movie][:title].blank?
      params[:movie][:title] = params[:movieold][:title]
    end
    if Movie.exists?(@movie)
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{params[:movieold][:title]} was successfully updated."
      redirect_to movies_path
    else
      flash[:notice] = "This Movie does not exist."
      redirect_to movies_updatemovie_path
    end
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end
  
  def deletebytitle
    @movie = Movie.find_by_title(params[:moviedelete][:title])
    if @movie == nil
      flash[:notice] = "This Movie does not exist"
      redirect_to movies_path
    else
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  end
  
  def deletebyrating
    count = 0
    while true
      @movie = Movie.find_by_rating(params[:moviedelete][:rating])
      if @movie != nil
        @movie.destroy
        count = count + 1
      else
        break
      end
    end
    flash[:notice] = "#{count} Movies Deleted"
    redirect_to movies_path
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
