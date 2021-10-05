class RoomDecorator < Draper::Decorator
  def self.collection_decorator_class
    PaginatingDecorator
  end
  delegate_all
  decorates_finders
  decorates_association :room_characteristics
  
  DEPARTMENTS = {
    "" => "All Units",
    "ACAD_&_BDGT_AFFAIRS" => "Academic and Budget Affairs",
    "COLLEGE_ENGINEERING" => "College of Engineering",
    "COLLEGE_OF_LSA" => "College of LSA",
    "COLLEGE_PHARMACY" => "College of Pharmacy",
    "COLL_ARCH_URN_PLN" => "College of Architecture and Urban Planning",
    "DBN_CHANCELLOR" => "Dearborn Chancellor",
    "DBN_COL_ARTS_SCI_LTR" => "Dearborn College of Arts, Science and Literature",
    "DBN_COL_BUSINESS" => "Dearborn College of Business",
    "DBN_COL_EDU_HLT_HS" => "Dearborn College of Education, Health, & Human Services",
    "DBN_COL_ENGINEERING" => "Dearborn College of Engineering & Computer Science",
    "DBN_LIBRY_MEDIA_SRVS" => "Dearborn Library Media Services",
    "DSA_HOUSING_SERVICES" => "Dearborn Housing Services",
    "FLINT_CAS" => "Flint College of Arts & Sciences",
    "FLINT_HLTH_PROF_STUD" => "Flint College of Health Sciences",
    "FLINT_MGMT_DEAN" => "Flint School of Management",
    "FLINT_PROVOST" => "Flint Office of the Provost",
    "FLINT_SCHEDU_HMN_SVS" => "Flint School of Education & Human Services",
    "FLINT_VC_ENROLLMENT" => "Flint Enrollment Management",
    "INST_SOC_RESEARCH" => "Institute for Social Research",
    "INTERCOLLEG_ATHLETIC" => "Intercollegiate Athletics",
    "LAW_SCHOOL" => "Law School",
    "MEDICAL_SCHOOL" => "Medical School",
    "SCHOOL_BUS_ADMIN" => "Ross School of Business",
    "SCHOOL_DENTISTRY" => "School of Dentistry",
    "SCHOOL_EDUCATION" => "School of Education",
    "SCHOOL_INFORMATION" => "School of Information",
    "SCHOOL_KINESIOLOGY" => "School of Kinesiology",
    "SCHOOL_MUSIC" => "School of Music, Theatre and Dance",
    "SCHOOL_NAT_RES_ENVIR" => "School for Environment and Sustainability",
    "SCHOOL_NURSING" => "School of Nursing",
    "SCHOOL_PUB_HEALTH" => "School of Public Health",
    "SCHOOL_PUB_POLICY" => "School of Public Policy",
    "SCHOOL_SOCIAL_WORK" => "School of Social Work",
    "VP_ACAD_GRAD_STUDY" => "Museum of Art",
  }

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  def title
    "#{room.room_number} #{room.building.nick_name.titleize}"
  end

  def address
    " #{room.building.address.titleize}, #{room.building.city.titleize}"
  end

  def created_at
    helpers.content_tag :span, class: "time" do
      object.created_at.strftime("%a %m/%d/%y")
    end
  end

  def department_name
    DEPARTMENTS[object.dept_grp]
  end

  def department_names
    DEPARTMENTS.each do |dept_id, dept_grp|
      dept_grp
    end
  end

  def student_capacity
    helpers.pluralize(room.instructional_seating_count, "Student")
  end

  def room_schedule_contact
    if
room.room_contact&.rm_schd_cntct_name
      "#{room.room_contact.rm_schd_cntct_name.titleize}"
    else
      "Not Available"
    end
  end

  def room_schedule_email
    if room.room_contact&.rm_schd_email
      "#{room.room_contact.rm_schd_email.downcase}"
    else
      "Not Available"
    end
  end

  def room_schedule_phone
    if
room.room_contact&.rm_schd_cntct_phone
      "#{room.room_contact.rm_schd_cntct_phone}"
    else
      "Not Available"
    end
  end

  def room_support_contact
    #  rm_sppt_cntct_url    :string
    if
room.room_contact&.rm_sppt_cntct_url
      "#{room.room_contact.rm_sppt_cntct_url} \n #{room.room_contact.rm_schd_email}".titleize
    else
      "Not Available"
    end
  end

  def room_support_email
    #  rm_sppt_cntct_url    :string
    if
room.room_contact&.rm_sppt_cntct_email
      "#{room.room_contact.rm_sppt_cntct_email}"
    else
      "Not Available"
    end
  end

  def room_support_phone
    #  rm_sppt_cntct_url    :string
    if
room.room_contact&.rm_sppt_cntct_phone
      "#{room.room_contact.rm_sppt_cntct_phone}"
    else
      "Not Available"
    end
  end


  def copy_text
    %(#{title.upcase} : #{address}. | Student Capacity: #{room.instructional_seating_count}. | You can find details at https://rooms.umich.edu/rooms/#{room.id} including links to support and scheduling for this room.)
  end
end
# class PaginatingDecorator < Draper::CollectionDecorator
#   delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?, :next_page
# end

class PaginatingDecorator < Draper::CollectionDecorator
  delegate :page, :items, :outset, :size, :page_param, :params, :anchor, :link_extra, :i18n_key, :cycle, :count
end