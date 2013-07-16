require 'net/http'
require 'json'

class DamsObjectsController < ApplicationController
  include Blacklight::Catalog
  include Dams::ControllerHelper
  load_and_authorize_resource
  skip_load_and_authorize_resource :only => :show

  ##############################################################################
  # solr actions ###############################################################
  ##############################################################################
  def show
    # check ip for unauthenticated users
    if current_user == nil
      current_user = User.anonymous(request.ip)
    end

    @document = get_single_doc_via_search(1, {:q => "id:#{params[:id]}"} )
    if @document.nil?
      raise ActionController::RoutingError.new('Not Found')
    end

    @rdfxml = @document['rdfxml_ssi']
    if @rdfxml == nil
      @rdfxml = "<rdf:RDF xmlns:dams='http://library.ucsd.edu/ontology/dams#'
          xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
          rdf:about='#{Rails.configuration.id_namespace}#{params[:id]}'>
  <dams:error>content missing</dams:error>
</rdf:RDF>"
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @document }
      format.rdf { render xml: @rdfxml }
    end
  end


  ##############################################################################
  # hydra actions ##############################################################
  ##############################################################################
  def view
    @dams_object = DamsObject.find(params[:id])
  end

  def new
  	@mads_complex_subjects = get_objects('MadsComplexSubject','name_tesim')
  	@dams_units = get_objects('DamsUnit','unit_name_tesim') 	
  	@dams_assembled_collections = get_objects('DamsAssembledCollection','title_tesim')
  	@dams_provenance_collections = get_objects('DamsProvenanceCollection','title_tesim')
  	@mads_languages =  get_objects('MadsLanguage','name_tesim')
  	@mads_authorities = get_objects('MadsAuthority','name_tesim')
  		
	#uri = URI('http://fast.oclc.org/fastSuggest/select')
	#res = Net::HTTP.post_form(uri, 'q' => 'suggestall :*', 'fl' => 'suggestall', 'wt' => 'json', 'rows' => '10')
	#json = JSON.parse(res.body)
	#@jdoc = json.fetch("response").fetch("docs")
	
	#@autocomplete_items = Array.new
	#@jdoc.each do |value|
	#	@autocomplete_items << value['suggestall']
	#end  

  end
  
  def edit
	@mads_complex_subjects = get_objects('MadsComplexSubject','name_tesim')
  end
  
  def create	  
  	@dams_object.attributes = params[:dams_object] 
  	if @dams_object.save
  		redirect_to @dams_object, notice: "Object has been saved"
  		#redirect_to edit_dams_object_path(@dams_object), notice: "Object has been saved"
    else
      flash[:alert] = "Unable to save object"
      render :new
    end
  end
  
  def update
    @dams_object.attributes = params[:dams_object]
  	if @dams_object.save
  		redirect_to @dams_object, notice: "Successfully updated object" 	
  		#redirect_to edit_dams_object_path(@dams_object), notice: "Successfully updated object"	
    else
      flash[:alert] = "Unable to save object"
      render :edit
    end
  end
end
