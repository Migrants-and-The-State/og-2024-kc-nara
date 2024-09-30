require 'fileutils'
require 'pdf-reader'
require 'vips'

pdf_dir     = '/Volumes/migrants_state/2024-KC-NARA/pdfs'
data_dir    = '/Volumes/migrants_state/2024-KC-NARA/jpgs'
pdfs        = Dir.glob("#{pdf_dir}/*.pdf")
pdfs_count  = pdfs.length

afiles_csv  = './src/afiles.csv'
pages_csv   = './src/pages.csv'

# write start of csvs
File.open(afiles_csv, 'w') do |file| 
  file.puts("id,label,og_pdf_id,page_count")
end

# write start of csvs
File.open(pages_csv, 'w') do |file| 
  file.puts("doc_id,label,a_number,page_number,extracted_text")
end

FileUtils.mkdir_p data_dir

# # process data
pdfs.each_with_index do |path, i|
  GC.start
  reader      = PDF::Reader.new(path)
  page_count  = reader.page_count
  og_pdf_id   = File.basename(path, '.pdf')
  a_number    = og_pdf_id.sub('_redacted', '').sub('_withdrawal', '')
  afile_data  = [a_number,a_number,og_pdf_id,page_count]

  File.open(afiles_csv, 'a') { |file| file.puts afile_data.join(',') } 
  FileUtils.mkdir_p "#{data_dir}/#{a_number}"

  (0..page_count - 1).each do |index|
    page_number     = index.to_s.rjust(4, "0")
    doc_id          = "#{a_number}_#{page_number}"
    target          = "#{data_dir}/#{a_number}/#{page_number}.jpg"
    extracted_text  = reader.pages[index].text.to_s.gsub(/\R+/, "|").gsub('"', "'")
    doc_data        = [doc_id,doc_id,a_number,page_number,"\"#{extracted_text}\""]

    File.open(pages_csv, "a") { |file| file.puts doc_data.join(',') }
    
    return if File.exist? target

    img     = Vips::Image.pdfload path, page: index, n: 1, dpi: 300
    img.jpegsave target
    
    print "writing #{File.basename target} page #{index} / #{page_count}\r"
    $stdout.flush
  end
  
  puts "finished pdf #{i+1}/#{pdfs_count} — process is #{(i.to_f / pdfs_count.to_f * 100.0).round(1)}% complete    \n"
end
