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
    order_by = params[:order_by];
    ratings = params[:ratings];
    redirect = ""; #Redirection url
    
    #Loading the rating values to be showed
    @all_ratings = Movie.all_ratings;
    
    #Invalid sort parameter, return default sorting
    if(order_by != "title" && order_by !="release_date") then 
      if(session[:order_by]) then
        order_by = session[:order_by];
        
        fragmented_url = request.url.split("?");
        if(fragmented_url.length == 2) then
          redirect = fragmented_url[0] + "?" + fragmented_url[1] + "&order_by=" + order_by;
        else
          redirect = fragmented_url[0] + "?order_by=" + order_by; 
        end
      else
        order_by = nil; #Default state, no order, no filter
      end
    else
      session[:order_by] = order_by;#Valid, store it in session
    end;
      
    @selected_order_criteria = order_by;#For checkbox
    
    #Validate if the user filtered the movies
    if(ratings) then
      filter_ratings = ratings.keys;
      session[:filter_ratings] = filter_ratings;
    else
      if (session[:filter_ratings]) then
        filter_ratings = session[:filter_ratings];
        
        #Generate url params
        filter_ratings_url = "";
        filter_ratings.each{|r|
          filter_ratings_url += "ratings[" + r+"]=ratings[" + r + "]&"
        }
        
        if (redirect == "") then
          redirect += "?" + filter_ratings_url;
        else
          redirect += "&" + filter_ratings_url;
        end
        
      else
        #Default, all the ratings selected
        filter_ratings = Movie.all_ratings;
        session[:filter_ratings] = filter_ratings;
      end
      
    end

    #Generate control variables for checkbox "checked"
    @selected_filters = {};
    filter_ratings.each{|f|
      @selected_filters[f] = true;
    }
  
    if(redirect != "") then
      flash.keep;
      redirect_to redirect;
    end
    
    @movies = order_by ? Movie.where({ rating: filter_ratings}).order(order_by) : Movie.where({ rating: filter_ratings})
      
  end

  def new
    # default: render 'new' template
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

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
end
