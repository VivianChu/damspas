require 'timeout'

class DamsResourceDatastream < ActiveFedora::RdfxmlRDFDatastream
  include Dams::DamsHelper
  rdf_subject { |ds|
    if ds.pid.nil?
      RDF::URI.new
    else
      RDF::URI.new(Rails.configuration.id_namespace + ds.pid)
    end
  }


  def load_collection (collection,assembledCollection,provenanceCollection,provenanceCollectionPart)
      collections = []
      [collection,assembledCollection,provenanceCollection,provenanceCollectionPart].each do |coltype|
        coltype.each do |col|
          begin
            # if we have usable metadata, use as-is
            if col.title.first != nil
              collections << col
              colfound = true
            end
          rescue
            colfound = false
          end
  
          if !colfound
            # if we don't, find the pid and fetch colobj from repo
            cpid = (col.class.name.include? "Collection") ? cpid = col.pid : col.to_s.gsub(/.*\//,'')
            begin
              collections << ActiveFedora::Base.find(cpid, :cast => true)
            rescue
              logger.warn "Couldn't load collection from repo: #{cpid}"
            end
          end
        end
      end
      collections
    end

   def load_unit(unit)
	if !unit.first.nil?
	    u_pid = unit.first.pid
	    
	    if !unit.first.name.first.nil? && unit.first.name.first.to_s.length > 0
	      unit.first
	    elsif u_pid.to_s.length > 0
          begin
	        DamsUnit.find(u_pid)
          rescue
            logger.warn "XXX: error loading unit: #{u_pid}"
          end
	    end
	else
		nil
	end

  end
  
 ## Language ##################################################################
  def load_languages
    load_languages(language)
  end
  def load_languages(language)
    languages = []
    begin
      language.each do |lang|
        foo = lang.to_s
        if lang.name.first != nil && lang.code.first != nil
          # use inline data if available
          languages << lang
        elsif lang.pid != nil && lang.pid.length > 0
          # load external records
          languages << MadsLanguage.find(lang.pid)
        end
      end
    rescue Exception => e
      puts "trapping language error"
      puts e.backtrace
    end
    languages
  end
   
  # tmp lang class
#  class Language
#    include ActiveFedora::RdfObject
#    include ActiveFedora::Rdf::DefaultNodes
#    rdf_type DAMS.Language
#
#    map_predicates do |map|
#      map.code(:in => DAMS, :to => 'code')
#      map.value(:in => RDF, :to => 'value')
#      map.valueURI(:in => DAMS, :to => 'valueURI')
#      map.vocab(:in => DAMS, :to => 'vocabulary', :class_name => 'DamsVocabulary')
#    end
#    rdf_subject { |ds| RDF::URI.new(Rails.configuration.id_namespace + ds.pid)}
#    def pid
#      rdf_subject.to_s.gsub(/.*\//,'')
#    end
#  end


 ## provenanceCollectionPart ##################################################################
  def load_provenanceCollectionParts
    load_provenanceCollectionParts(provenanceCollectionPart)
  end
  def load_provenanceCollectionParts(provenanceCollectionPart)
    provenanceCollectionParts = []
    begin
      provenanceCollectionPart.each do |part|
        if part.title.first != nil 
          # use inline data if available
          provenanceCollectionParts << part
        elsif part.pid != nil
          # load external records
          provenanceCollectionParts << DamsProvenanceCollectionPart.find(part.pid)
        end
      end
    rescue Exception => e
      puts "trapping provenanceCollectionPart error"
      puts e.backtrace
    end
    provenanceCollectionParts
  end

## provenanceCollection ##################################################################
  def load_provenanceCollections
    load_provenanceCollections(provenanceCollection)
  end
  def load_provenanceCollections(provenanceCollection)
    provenanceCollections = []
    begin
      provenanceCollection.each do |part|
        if part.title.first != nil 
          # use inline data if available
          provenanceCollections << part
        elsif part.pid != nil
          # load external records
          provenanceCollections << DamsProvenanceCollection.find(part.pid)
        end
      end
    rescue Exception => e
      puts "trapping provenanceCollection error"
      puts e.backtrace
    end
    provenanceCollections
  end

  ## Subject ###################################################################

  # MADS complex subjects
  def load_complexSubjects
    loadComplexSubjects(complexSubject)
  end
  def load_complexSubjects(complexSubject)
	loadMadsObjects complexSubject,MadsComplexSubject
  end

  # MADS simple subjects + extensions (VRA, etc.)
  def load_builtWorkPlaces
    load_builtWorkPlaces(builtWorkPlace)
  end
  def load_builtWorkPlaces(builtWorkPlace)
	loadMadsObjects builtWorkPlace,DamsBuiltWorkPlace
  end
  def load_culturalContexts
    load_culturalContexts(culturalContext)
  end
  def load_culturalContexts(culturalContext)
	loadMadsObjects culturalContext,DamsCulturalContext
  end
  def load_functions
    load_functions(function)
  end
  def load_functions(function)
	loadMadsObjects function,DamsFunction
  end
  def load_genreForms
    load_genreForms(genreForm)
  end
  def load_genreForms(genreForm)
	loadMadsObjects genreForm,MadsGenreForm
  end
  def load_geographics
    load_geographics(geographic)
  end
  def load_geographics(geographic)
	loadMadsObjects geographic,MadsGeographic
  end
  def load_iconographies
    load_iconographies(iconography)
  end
  def load_iconographies(iconography)
    loadMadsObjects iconography,DamsIconography
  end
  def load_occupations
    load_occupations(occupation)
  end
  def load_occupations(occupation)
	loadMadsObjects occupation,MadsOccupation
  end
  def load_scientificNames
    load_scientificNames(scientificName)
  end
  def load_scientificNames(scientificName)
	loadMadsObjects scientificName,DamsScientificName
  end
  def load_stylePeriods
    load_stylePeriods(stylePeriod)
  end
  def load_stylePeriods(stylePeriod)
	loadMadsObjects stylePeriod,DamsStylePeriod
  end
  def load_techniques
    load_techniques(technique)
  end
  def load_techniques(technique)
	loadMadsObjects technique,DamsTechnique
  end
  def load_temporals
    load_temporals( temporal )
  end
  def load_temporals( temporal )
	loadMadsObjects temporal,MadsTemporal
  end
  def load_topics
    load_topics(topic)
  end
  def load_topics(topic)
	loadMadsObjects topic,MadsTopic
  end

  # MADS names
  def load_names
    load_names(name)
  end
  def load_names(name)
	loadMadsObjects name,MadsName
  end
  def load_conferenceNames
    load_conferenceNames(conferenceName)
  end
  def load_conferenceNames(conferenceName)
	loadMadsObjects conferenceName,MadsConferenceName
  end
  def load_corporateNames
    load_corporateNames(corporateName)
  end
  def load_corporateNames(corporateName)
	loadMadsObjects corporateName,MadsCorporateName
  end
  def load_familyNames
    load_familyNames(familyName)
  end
  def load_familyNames(familyName)
	loadMadsObjects familyName,MadsFamilyName
  end
  def load_personalNames
    load_personalNames(personalName)
  end
  def load_personalNames(personalName)
	loadMadsObjects personalName,MadsPersonalName
  end

  ## Event #####################################################################
  def load_events
    load_events(event)
  end
  def load_events(event)
    events = []
    event.each do |e|
      begin
	      if !e.outcome.first.nil? && e.outcome.first != ""
	        # use inline data if available
	        events << e
	      elsif e.pid != nil
	        events << DamsEvent.find(e.pid)
	      end
 	  rescue Exception => e
          puts e.to_s
          puts e.backtrace
      end 	      	      
    end
    events
  end  


  ## helpers ###################################################################

  # helper method for recursing over component hierarchy
  def find_children(p)
    kids = @parents[p]
    if kids != nil && kids.length > 0

      # replace children with nested hashes recursively
      for i in 0 .. kids.length
        cid = kids[i]
        if @parents[cid] != nil && @parents[cid].length > 0
          grandkids = find_children(cid)
          kids[i] = {cid => grandkids}
        end
      end
    end
    kids
  end

  # helper method to load external mads classes
  def loadMadsObjects (object,className)
    objects = []
    object.each do |o|
      if o.to_s.include?("Internal") && !o.name.first.blank?
        # inline records, use as-is
        objects << o
      elsif o.to_s.include?("Internal") && o.name.first.blank? && !o.pid.blank?
        # external records, use pid and fetch from repo
        if !o.pid.start_with?("_")
          o2 = className.find(o.pid)
          objects << o2
        end
      else
        # unmapped records, get pid from URI and fetch from repo
        pid = o.to_s.gsub(/.*\//,'')
        if !pid.blank?
      	  o2 = className.find(pid)
          objects << o2
        end
      end
    end
  	return objects
  end

  ## Solr ######################################################################
  def insertFields (solr_doc, fieldName, objects)
    if objects != nil
      objects.each do |obj|
        Solrizer.insert_field(solr_doc, fieldName, obj.name)
        Solrizer.insert_field(solr_doc, "all_fields", obj.name)
      end
    end
  end
  def insertNameFields (solr_doc, fieldName, objects)
    insertFields( solr_doc, fieldName, objects )
    insertFacets( solr_doc, 'subject_topic', objects )
    if objects != nil
      insertFacets( solr_doc, "name", objects )
      objects.each do |obj|
        Solrizer.insert_field(solr_doc, "name", obj.name)
      end
    end
    reload MadsPersonalNameInternal
    reload MadsNameInternal
    reload MadsConferenceNameInternal
    reload MadsCorporateNameInternal
    reload MadsFamilyNameInternal
  end
  def insertFacets (solr_doc, fieldName, objects)
    facetable = Solrizer::Descriptor.new(:string, :indexed, :multivalued)
    if objects != nil
      objects.each do |obj|
        Solrizer.insert_field(solr_doc, fieldName, obj.name,facetable)
      end
    end
  end
  def insertSubjectFields( solr_doc, fieldName, objects )
    insertFields solr_doc, fieldName, objects
    insertFacets solr_doc, 'subject_topic', objects
  end

  def insertComplexSubjectFields (solr_doc, cid, objects)
    prefix = (cid != nil) ? "component_#{cid}_" : ""
    facetable = Solrizer::Descriptor.new(:string, :indexed, :multivalued)
    if objects != nil
      objects.each do |obj|
          Solrizer.insert_field(solr_doc, "#{prefix}complexSubject", obj.name)
          Solrizer.insert_field(solr_doc, 'subject', obj.name)
          Solrizer.insert_field(solr_doc, "#{prefix}subject_topic", obj.name, facetable)
          Solrizer.insert_field(solr_doc, "subject_topic", obj.name, facetable)
          Solrizer.insert_field(solr_doc, "all_fields", obj.name)
      end
    end
  end

  def insertNoteFields (solr_doc, fieldName, objects)
    objects.map do |no|
      note_json = {}
      note_obj = nil
      note_uri = no.to_s
	  if no.value.first.nil? && no.pid != nil && !no.pid.start_with?("_:")
        note_obj = no.load
        note_json[:id] = note_obj.pid.first      
      else 
      	note_obj = no
      end
        
      note_json.merge!( :type => note_obj.type.first.to_s,
                       :value => note_obj.value.first.to_s,
                :displayLabel => note_obj.displayLabel.first.to_s )
      Solrizer.insert_field(solr_doc, "#{fieldName}_json", note_json.to_json )

      # retrieval
      Solrizer.insert_field(solr_doc, "#{fieldName}", note_obj.value )
      Solrizer.insert_field(solr_doc, "note", note_obj.value )
      Solrizer.insert_field(solr_doc, "all_fields", note_obj.value)
    end
  end
  def insertDateFields (solr_doc, cid, dates)
    creation_date = nil
    other_date = nil

    dates.map do |date|
      # display
      if cid != nil
        date_json = {:beginDate=>date.beginDate.first.to_s, :endDate=>date.endDate.first.to_s, :value=>date.value.first.to_s, :type=>date.type.first.to_s, :encoding=>date.encoding.first.to_s }
        Solrizer.insert_field(solr_doc, "component_#{cid}_date_json", date_json.to_json)
      else
        date_json = {
          :beginDate=>date.beginDate.first.to_s,
          :endDate=>date.endDate.first.to_s,
          :value=>date.value.first.to_s,
          :type=>date.type.first.to_s,
          :encoding=>date.encoding.first.to_s
        }
        Solrizer.insert_field(solr_doc, "date_json", date_json.to_json)
      end

      # retrieval
      Solrizer.insert_field(solr_doc, "date", date.value.first)
      Solrizer.insert_field(solr_doc, "date", date.beginDate.first)
      Solrizer.insert_field(solr_doc, "date", date.endDate.first)
      Solrizer.insert_field(solr_doc, "date", date.type.first)
      Solrizer.insert_field(solr_doc, "date", date.encoding.first)
      Solrizer.insert_field(solr_doc, "all_fields", date.value)
      Solrizer.insert_field(solr_doc, "all_fields", date.beginDate)
      Solrizer.insert_field(solr_doc, "all_fields", date.endDate)
      Solrizer.insert_field(solr_doc, "all_fields", date.type)
      Solrizer.insert_field(solr_doc, "all_fields", date.encoding)

      # save dates for sort date
      begin
        # get date string from value or beginDate
        dateVal = nil
        dateBeg = nil
        if(!date.nil? && !date.value.empty?)
          dateVal = clean_date date.value.first
        end
      	if(!date.nil? && !date.beginDate.empty?)
          dateBeg = clean_date date.beginDate.first
        end

        # parse dates
        if(!dateVal.blank?)
          if date.type.first == 'creation'
            begin
              creation_date = DateTime.parse(dateVal) if creation_date.nil?
            rescue
              creation_date = DateTime.parse(dateBeg) if creation_date.nil?
            end
          else
            begin
              other_date = DateTime.parse(dateVal) if other_date.nil?
            rescue
              other_date = DateTime.parse(dateBeg) if other_date.nil?
            end
          end
        end
      rescue Exception => e
        logger.info "error parsing date '#{dateVal}' (#{e.to_s})"
        #puts e.backtrace
      end
    end

    datesort = Solrizer::Descriptor.new(:date, :indexed, :stored)
    if creation_date
      Solrizer.insert_field(solr_doc, "object_create", creation_date, datesort)
    elsif other_date
      Solrizer.insert_field(solr_doc, "object_create", other_date, datesort)
    end
  end
  def clean_date( date )
    d = date || ''
    # pad yyyy or yyyy-mm dates out to yyyy-mm-dd
    if d.match( '^\d{4}$' )
      d += "-01-01"
    elsif d.match( '^\d{4}-\d{2}$' )
      d += "-01"
    end

    # remove everything after yyyy-mm-dd unless we have a full iso8601 date
    if d.match('^\d{4}-\d{2}-\d{2}')
      unless d.match('^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')
        d = d[0,10]
      end
    end
    d
  end
  def insertRelationshipFields ( solr_doc, prefix, relationships )

    facetable = Solrizer::Descriptor.new(:string, :indexed, :multivalued)
    # build map: role => [name1,name2]
    rels = {}
    relationships.map do |relationship|
      obj = relationship.name.first.to_s      

      rel = nil
	  if !relationship.corporateName.first.nil?
	    rel = relationship.corporateName
	  elsif !relationship.personalName.first.nil?
	    rel = relationship.personalName
	  elsif !relationship.conferenceName.first.nil?
	    rel = relationship.conferenceName
	  elsif !relationship.familyName.first.nil?
	    rel = relationship.familyName 	     	        
      elsif !relationship.name.first.nil?
	    rel = relationship.name    
	  end

      foo = rel.to_s
      if rel != nil && (rel.first.nil? || rel.first.name.first.nil?)
        rel = relationship.load  
      end

      if ( rel != nil )
        if(rel.to_s.include? 'Internal')
            name = rel.first.name.first.to_s
            Solrizer.insert_field(solr_doc, "all_fields", rel.first.name)
        else
            name = rel.name.first.to_s
            Solrizer.insert_field(solr_doc, "all_fields", rel.name)
        end

        # retrieval
        Solrizer.insert_field( solr_doc, "name", name )
        
        begin        
          relRole = relationship.role.first.name.first.to_s
          foo = relRole.to_s
          
          # display     
        
          if !relRole.nil? && relRole != ''
            roleValue = relRole
          else 
            role = relationship.loadRole
            if role != nil
              roleValue = role.name.first.to_s
            end
          end
          Solrizer.insert_field(solr_doc, "all_fields", roleValue)
          Solrizer.insert_field(solr_doc, "creator", name, facetable)
          	  
          if rels[roleValue] == nil
            rels[roleValue] = [name]
          else
            rels[roleValue] << name
          end
        rescue Exception => e
          puts "trapping role error in relationship"
          puts e.backtrace
        end
      end
    end

    # sort names
    rels.each_key do |role|
      rels[role] = rels[role].sort
    end

    # add to solr
    Solrizer.insert_field( solr_doc, "#{prefix}relationship_json", rels.to_json )
  end
  def insertTitleFields ( solr_doc, cid, titles )
    sort_title = ""
    titles.each do |t|
      if(t.name.class == ActiveFedora::RdfNode::TermProxy)
      	name = t.name.first || ""
      else
      	name = t.name || ""
      end
      external = t.externalAuthority || ""

      # walk through chain of title elements
      value = t.value || ""
      nonSort = t.nonSort || ""
      partName = t.partName || ""
      partNumber = t.partNumber || ""
      subtitle = t.subtitle || ""
	  variant = t.variant || ""
	  translationVariant = t.translationVariant || ""
	  abbreviationVariant = t.abbreviationVariant || ""
	  acronymVariant = t.acronymVariant || ""
	  expansionVariant = t.expansionVariant || ""
	  
      # structured
      title_json = { :name => name, :external => external, :value => value,
                     :nonSort => nonSort, :partName => partName,
                     :partNumber => partNumber, :subtitle => subtitle, 
                     :variant => variant, :translationVariant => translationVariant,
                     :abbreviationVariant => abbreviationVariant, :acronymVariant => acronymVariant,
                     :expansionVariant => expansionVariant }
      if cid != nil
        Solrizer.insert_field(solr_doc, "component_#{cid}_title_json", title_json.to_json)
      else
        Solrizer.insert_field(solr_doc, "title_json", title_json.to_json)
      end

      # retrieval
      Solrizer.insert_field(solr_doc, "title", name)
      Solrizer.insert_field(solr_doc, "all_fields", name)
	  Solrizer.insert_field(solr_doc, "all_fields", external) if external.length > 0
	  #Solrizer.insert_field(solr_doc, "all_fields", value) if value.length > 0
	  Solrizer.insert_field(solr_doc, "all_fields", nonSort) if nonSort.length > 0
	  Solrizer.insert_field(solr_doc, "all_fields", partName) if partName.length > 0
	  Solrizer.insert_field(solr_doc, "all_fields", partNumber) if partNumber.length > 0
	  Solrizer.insert_field(solr_doc, "all_fields", subtitle) if subtitle.length > 0
	        
      if variant.length > 0
      	Solrizer.insert_field(solr_doc, "titleVariant", variant)
      	Solrizer.insert_field(solr_doc, "all_fields", variant)
      end 
      if translationVariant.length > 0
      	Solrizer.insert_field(solr_doc, "titleTranslationVariant", translationVariant)
      	Solrizer.insert_field(solr_doc, "all_fields", translationVariant)
      end
      if abbreviationVariant.length > 0
      	Solrizer.insert_field(solr_doc, "titleAbbreviationVariant", abbreviationVariant)
      	Solrizer.insert_field(solr_doc, "all_fields", abbreviationVariant)
      end
      if acronymVariant.length > 0
      	Solrizer.insert_field(solr_doc, "titleAcronymVariant", acronymVariant)
      	Solrizer.insert_field(solr_doc, "all_fields", acronymVariant)
      end
      if expansionVariant.length > 0
      	Solrizer.insert_field(solr_doc, "titleExpansionVariant", expansionVariant) 
        Solrizer.insert_field(solr_doc, "all_fields", expansionVariant)
      end
	  	  		
      # build sort title
      if sort_title == "" && cid == nil
        sort_title = name
      end
    end

    # add sort title (out of loop to make sure only once)
    if cid == nil && !sort_title.blank?
      Solrizer.insert_field(solr_doc, "title", sort_title.downcase, Solrizer::Descriptor.new(:string, :indexed, :stored))
    end
  end
  def insertLanguageFields ( solr_doc, field, languages )
    langs = load_languages languages
    if langs != nil
      n = 0
      langs.map.each do |lang|
        foo = lang.to_s
        n += 1
        begin
	      language_json = {}
	      language_obj = nil
	      language_uri = lang.to_s
		  if lang.name.first.nil? && lang.pid != nil && !lang.pid.start_with?("_:")
	        language_obj = MadsLanguage.find(lang.pid)
	        language_json[:id] = language_obj.pid
	      else 
	        language_obj = lang
	      end
	          
	      language_json.merge!( :name => language_obj.name.first.to_s,
	                         :code => language_obj.code.first.to_s,
	                  :externalAuthority => language_obj.externalAuthority.first.to_s )
	      Solrizer.insert_field(solr_doc, "#{field}_json", language_json.to_json )
	
	      # retrieval
	      Solrizer.insert_field(solr_doc, "#{field}", language_obj.name )
	      Solrizer.insert_field(solr_doc, "all_fields", language_obj.name)        
        rescue Exception => e
          puts "XXX: error loading language: #{lang}: #{e.to_s}"
        end
      end
    end
  end

  # def insertProvenanceCollectionPartFields ( solr_doc, field, provenanceCollectionParts )
  #   parts = load_provenanceCollectionParts provenanceCollectionParts
  #   if parts != nil
  #     n = 0
  #     parts.map.each do |part|
  #       n += 1

  #       Solrizer.insert_field(solr_doc, 'part_name', part.title.first.value)
  #       Solrizer.insert_field(solr_doc, 'part_id', part.pid)
  #     end
  #   end
  # end

  def thumbnail( relatedResource )
    relatedResource.map do |resource|
      if resource.type.first.to_s == "thumbnail" && resource.uri.first != nil
        return resource.uri.first.to_s
      end
    end
  end
  def insertRelatedResourceFields ( solr_doc, prefix, relatedResource )
    # relatedResource
    n = 0
    relatedResource.map do |resource|
      n += 1
       begin
	      related_json = {}
	      related_obj = nil
	      related_uri = resource.to_s
		  if resource.type.first.nil? && resource.pid != nil && !resource.pid.start_with?("_:")
	        related_obj = DamsRelatedResource.find(resource.pid)
	        related_json[:id] = related_obj.pid
	      else 
	        related_obj = resource
	      end
	          
	      related_json = {:type=>related_obj.type.first.to_s, :uri=>related_obj.uri.first.to_s, :description=>related_obj.description.first.to_s}
	      Solrizer.insert_field(solr_doc, "related_resource_json", related_json.to_json)
	      Solrizer.insert_field(solr_doc, "all_fields", related_obj.uri.first.to_s)
	      Solrizer.insert_field(solr_doc, "all_fields", related_obj.type.first.to_s)
	      Solrizer.insert_field(solr_doc, "all_fields", related_obj.description.first.to_s)
	      if resource.type.first.to_s == "thumbnail"
	        Solrizer.insert_field(solr_doc, "thumbnail", resource.uri.first.to_s)
	      end      
	  rescue Exception => e
	      puts "XXX: error loading relatedResource: #{resource}: #{e.to_s}"
	  end
        
      #related_json = {:type=>resource.type.first.to_s, :uri=>resource.uri.first.to_s, :description=>resource.description.first.to_s}
      #Solrizer.insert_field(solr_doc, "related_resource_json", related_json.to_json)
      #Solrizer.insert_field(solr_doc, "all_fields", resource.uri.first.to_s)
      #Solrizer.insert_field(solr_doc, "all_fields", resource.type.first.to_s)
      #Solrizer.insert_field(solr_doc, "all_fields", resource.description.first.to_s)
      #if resource.type.first.to_s == "thumbnail"
      #  Solrizer.insert_field(solr_doc, "thumbnail", resource.uri.first.to_s)
      #end
    end

    reload DamsRelatedResourceInternal
  end

  def events_to_json( event )
    event_array = []
    events = load_events event
    if events != nil
      n = 0
      events.each do |e|
        n += 1
        rels = []
                     
        e.relationship.map do |relationship|
	      obj = relationship.name.first.to_s      

	 	  rel = relationship
		    if !rel.corporateName.first.nil?
		      rel = rel.corporateName
		    elsif !rel.personalName.first.nil?
		      rel = rel.personalName    
			elsif !rel.name.first.nil?
		      rel = rel.name    
		      if rel.first.name.first.nil?
		      	rel = relationship.load  
		      end
		    end
          rel_json = {}
	      if (rel != nil)
			 if(rel.instance_of?(DamsRelationshipInternal) )
	        	name = rel.name.first.to_s
	         else
	        	name = rel.name.first.to_s			        	
			 end	      
             rel_json[:name] = name
          else
            if !relationship.name.first.nil? && !relationship.name.first.pid.nil? && (relationship.name.first.pid.include? 'dams:')
				rel_json[:name] = relationship.name.first.pid		
			end	     
	      end 
	      #relRole = relationship.loadRole
          begin
		    relRole = relationship.role.first.name.first.to_s
	        # display     
	        
	        if !relRole.nil? && relRole != ''
	        	roleValue = relRole
			else 
			  role = relationship.loadRole
			  if role != nil
			  	roleValue = role.name.first.to_s
			  end
			end	      
	        if (roleValue != nil)
               rel_json[:role] = roleValue
            else
			  if !relationship.role.first.nil? && !relationship.role.first.pid.nil? && (relationship.role.first.pid.include? 'dams:')
				rel_json[:role] = relationship.role.first.pid		
			  end	           
	        end  
          rescue
            puts "trapping role error in event for name: #{name}"
          end
          rels << rel_json
	    end    

        event_array << { :pid=>e.pid, :type=>e.type.first.to_s, :date=>e.eventDate.first.to_s, :outcome=>e.outcome.first.to_s, :relationship=>rels }
      end
    end
    event_array
  end
  def insertEventFields ( solr_doc, prefix, event )
    event_array = events_to_json event
    event_array.each do |e|
      Solrizer.insert_field(solr_doc, "#{prefix}event_json", e.to_json)
    end
  end

  def insertCollectionFields (solr_doc, fieldName, objects, className)
  	i = 0
    objects.map do |part|
      part_json = {}
      part_obj = nil
      part_uri = part.to_s
      part_pid = part_uri.gsub(/.*\//,'')

	  if !part_pid.nil? && part_pid.length > 0
        part_obj = className.find(part_pid)
        part_json[:id] = part_pid    
      end
      if !part_obj.nil?
      	if i == 0
    	  Solrizer.insert_field(solr_doc, "#{fieldName}_name", part_obj.title.first.value)
 		  Solrizer.insert_field(solr_doc, "#{fieldName}_id", part_pid)
      	end  
      	part_json.merge!(:name => part_obj.title.first.value,
                       :thumbnail => thumbnail(part_obj.relatedResource) )
      	Solrizer.insert_field(solr_doc, "#{fieldName}_json", part_json.to_json )
      end
      i = i + 1
    end
  end

  def insertUnitFields (solr_doc, unit)
    u = load_unit unit
    if !u.nil?
      Solrizer.insert_field(solr_doc, 'unit', u.name)
      Solrizer.insert_field(solr_doc, 'unit_code', u.code)
      Solrizer.insert_field(solr_doc, 'all_fields', u.name)
      Solrizer.insert_field(solr_doc, 'all_fields', u.code)
      unit_json = {
        :id => u.pid,
        :code => u.code.first.to_s,
        :name => u.name.first.to_s
      }
      Solrizer.insert_field(solr_doc, 'unit_json', unit_json.to_json)
    end    
  end
   
  # field types
  def to_solr (solr_doc = {})
    super(solr_doc)

    facetable = Solrizer::Descriptor.new(:string, :indexed, :multivalued)

    # title
    insertTitleFields solr_doc, nil, title

    # date
    insertDateFields solr_doc, nil, date

    # relationship
    insertRelationshipFields solr_doc, "", relationship

    # language
    insertLanguageFields solr_doc, "language", language
    
    # provenanceCollectionPart
    #insertProvenanceCollectionPartFields solr_doc, "provenanceCollectionPart", provenanceCollectionPart

    # note
    insertNoteFields solr_doc, 'otherNote', note
    insertNoteFields solr_doc, 'custodialResponsibilityNote', custodialResponsibilityNote
    insertNoteFields solr_doc, 'preferredCitationNote', preferredCitationNote
    insertNoteFields solr_doc, 'scopeContentNote', scopeContentNote

    # subject - old
    subject.map do |sn|
      #subject_value = sn.external? ? sn.load.name : sn.authoritativeLabel
      if sn != nil && sn.name.first.nil? && sn.pid != nil    
        subject_value = sn.load.name      
      else 
      	subject_value = sn.name
      end   
      Solrizer.insert_field(solr_doc, 'subject', subject_value)
      Solrizer.insert_field(solr_doc, 'all_fields', subject_value)
      Solrizer.insert_field(solr_doc, 'subject_topic', subject_value, facetable)
    end

    # subject - complex
    insertComplexSubjectFields solr_doc, nil, load_complexSubjects(complexSubject)

    # subject - simple
    #insertFields solr_doc, 'builtWorkPlace', load_builtWorkPlaces(builtWorkPlace)
    #insertFields solr_doc, 'culturalContext', load_culturalContexts(culturalContext)
    #insertFields solr_doc, 'function', load_functions(function)
    #insertFields solr_doc, 'iconography', load_iconographies(iconography)
    #insertFields solr_doc, 'occupation', load_occupations(occupation)
    #insertFields solr_doc, 'scientificName', load_scientificNames(scientificName)
    #insertFields solr_doc, 'stylePeriod', load_stylePeriods(stylePeriod)
    #insertFields solr_doc, 'technique', load_techniques(technique)
    #insertFields solr_doc, 'temporal', load_temporals(temporal)

    # subjects bundled under "Subjects" heading
    insertSubjectFields solr_doc, 'genreForm', load_genreForms(genreForm)
    insertSubjectFields solr_doc, 'geographic', load_geographics(geographic)
    insertSubjectFields solr_doc, 'topic', load_topics(topic)
    insertSubjectFields solr_doc, 'temporal', load_temporals(temporal)
	insertSubjectFields solr_doc, 'builtWorkPlace', load_builtWorkPlaces(builtWorkPlace)
    insertSubjectFields solr_doc, 'culturalContext', load_culturalContexts(culturalContext)
    insertSubjectFields solr_doc, 'function', load_functions(function)
    insertSubjectFields solr_doc, 'iconography', load_iconographies(iconography)
    insertSubjectFields solr_doc, 'occupation', load_occupations(occupation)
    insertSubjectFields solr_doc, 'scientificName', load_scientificNames(scientificName)
    insertSubjectFields solr_doc, 'stylePeriod', load_stylePeriods(stylePeriod)
    insertSubjectFields solr_doc, 'technique', load_techniques(technique)
    
    # subject - names
    insertNameFields solr_doc, 'other_name', load_names(name)
    insertNameFields solr_doc, 'conferenceName', load_conferenceNames(conferenceName)
    insertNameFields solr_doc, 'corporateName', load_corporateNames(corporateName)
    insertNameFields solr_doc, 'familyName', load_familyNames(familyName)
    insertNameFields solr_doc, 'personalName', load_personalNames(personalName)

    insertRelatedResourceFields solr_doc, "", relatedResource

    # event
    #insertEventFields solr_doc, "", event

    # rdf/xml for end-user
    begin
      Timeout::timeout(5) do
        Solrizer.insert_field(solr_doc, "rdfxml", self.content, Solrizer::Descriptor.new(:string, :indexed, :stored))
      end
    rescue Timeout::Error
      puts "RDF/XML indexing timeout"
    end

    # hack to strip "+00:00" from end of dates, because that makes solr barf
    ['system_create_dtsi','system_modified_dtsi','object_create_dtsi'].each {|f|
      if solr_doc[f].kind_of?(Array)
        solr_doc[f][0] = solr_doc[f][0].gsub('+00:00','Z')
      elsif solr_doc[f] != nil
        solr_doc[f] = solr_doc[f].gsub('+00:00','Z')
      end
    }
    return solr_doc
  end
end
