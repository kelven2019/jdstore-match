class ProductsController < ApplicationController
  before_action :validate_search_key, only:[:search]
  before_action :find_product, only: [:show,:add_to_cart]
  def index
    validate_genre_key
    validate_location_key
    @products_index = Product.all
    if @genre.blank? and @location.blank?
      @products=Product.all
    else

      if !@genre.blank?
        @products = Product.where(genre:@genre)
        @genre_show = @genre
      end

      if !@location.blank?
        @products = Product.where(location:@location)
        @location_show = @location
      end

    end
    @products = @products.paginate(:page => params[:page], :per_page => 12)

  end



  def show
    @review=Review.new

    @hash = Gmaps4rails.build_markers(@product) do |product, marker|
      marker.lat product.lat.to_f
      marker.lng product.lng.to_f
      marker.title product.location
      marker.picture({
                       :url => "/assets/images/location.png",
                       :width   => 20,
                       :height  => 35}
                     )
    end
  end

  def add_to_cart
    @product = Product.find(params[:id])
    if !current_cart.products.include?(@product)
      current_cart.add_product_to_cart(@product)
      # flash[:notice] = "Add to cart"
    else
      # flash[:warning] = "#{@product.title} is already in cart"
    end
    redirect_to :back
  end

  def search
    if @query_string.present?
      search_result = Product.ransack(@search_criteria).result(:distinct=>true)
      @products = search_result.paginate(:page=>params[:page],:per_page => 12)
    end
  end

  protected

  def validate_search_key
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?
    @search_criteria = search_criteria(@query_string)
  end

  def search_criteria(query_string)
    {:title_or_description_cont=>query_string}
  end

  def validate_genre_key
    @genre = params[:genre].gsub(/\\|\'|\/|\?/, "") if params[:genre].present?
  end
  def validate_location_key
    @location = params[:location].gsub(/\\|\'|\/|\?/, "") if params[:location].present?
  end

  private

  def find_product
    @product = Product.find_by_friendly_id(params[:id])
  end
end
