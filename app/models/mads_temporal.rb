class MadsTemporal < ActiveFedora::Base
  has_metadata 'damsMetadata', :type => MadsTemporalDatastream 
  has_attributes :name, :elementList, :scheme, :externalAuthority, :temporalElement_attributes, :temporalElement, :scheme_attributes, datastream: :damsMetadata, multiple: true
  
  #validates_length_of :name, :minimum => 2
  validates :name, :presence => true
  #validates_presence_of :name
end
