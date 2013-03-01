class DamsDatastream < ActiveFedora::RdfxmlRDFDatastream
    
 rdf_subject { |ds| RDF::URI.new(Rails.configuration.id_namespace + ds.pid)}

  def valueURI=(val)
    @valURI = RDF::Resource.new(val)
  end
  def valueURI
    if @valURI != nil
      @valURI
    else
      valURI
    end
  end
    
  def serialize    
    graph.insert([rdf_subject, DAMS.valueURI, @valURI]) if new?
    super
  end
  
  class List 
    include ActiveFedora::RdfList
    class IconographyElement
      include ActiveFedora::RdfObject
      rdf_type DAMS.IconographyElement
      map_predicates do |map|   
        map.elementValue(:in=> MADS)
      end
    end
    class ScientificNameElement
      include ActiveFedora::RdfObject
      rdf_type DAMS.ScientificNameElement
      map_predicates do |map|   
        map.elementValue(:in=> MADS)
      end
    end    
  end
    
  def to_solr (solr_doc = {}) 
    Solrizer.insert_field(solr_doc, 'name', name)
	Solrizer.insert_field(solr_doc, 'authority', authority)
    Solrizer.insert_field(solr_doc, "valueURI", valueURI.first.to_s)

	list = elementList.first
	i = 0
	if list != nil
		while i < list.size  do
		  if (list[i].class == DamsDatastream::List::IconographyElement)
			Solrizer.insert_field(solr_doc, 'iconography_element', list[i].elementValue.first)	
		  elsif (list[i].class == DamsDatastream::List::ScientificNameElement)
			Solrizer.insert_field(solr_doc, 'scientificName_element', list[i].elementValue.first)																			
		  end		  
		  i +=1
		end   
	end
	          			
 # hack to strip "+00:00" from end of dates, because that makes solr barf
    ['system_create_dtsi','system_modified_dtsi'].each { |f|
      if solr_doc[f].kind_of?(Array)
        solr_doc[f][0] = solr_doc[f][0].gsub('+00:00','Z')
      elsif solr_doc[f] != nil
        solr_doc[f] = solr_doc[f].gsub('+00:00','Z')
      end
    }
    return solr_doc
  end

end

