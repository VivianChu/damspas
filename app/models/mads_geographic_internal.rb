class MadsGeographicInternal < ActiveFedora::Rdf::Resource
  include Dams::MadsGeographic
  def pid
      rdf_subject.to_s.gsub(/.*\//,'')
  end
  def persisted?
    rdf_subject.kind_of? RDF::URI
  end  
end
