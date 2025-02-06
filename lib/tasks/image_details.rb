#!/usr/bin/env ruby
#
# Shell alias: `alias imgdetails='rails runner lib/tasks/image_details.rb'`
# run with: `imgdetails 'filename.jpg'`

def get_image_details(filename)
  blob = ActiveStorage::Blob.find_by(filename:)
  if blob
    puts "\n=== Image Details ==="
    puts "Filename: #{blob.filename}"
    puts "Key: #{blob.key}"
    puts "Content Type: #{blob.content_type}"
    puts "Byte Size: #{blob.byte_size} bytes (#{(blob.byte_size.to_f / 1024).round(2)} KB)"
    puts "Created: #{blob.created_at}"

    attachment = ActiveStorage::Attachment.find_by(blob_id: blob.id)
    if attachment
      record = attachment.record
      puts "\n=== Attachment Details ==="
      puts "Attached to: #{attachment.record_type} ##{attachment.record_id}"
      puts "Room Code: #{record.facility_code_heprod}" if record.respond_to?(:facility_code_heprod)
      puts "Attachment Name: #{attachment.name}"
    end
  else
    puts "No image found with filename: #{filename}"
  end
end

# Get filename from command line argument
filename = ARGV[0]
if filename.nil?
  puts 'Please provide a filename as an argument'
  puts "Usage: rails runner lib/tasks/image_details.rb 'filename.jpg'"
  exit
end

get_image_details(filename)
