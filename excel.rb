require 'fileutils'
require 'win32ole'

class ExcelConst
	@const_defined = Hash.new
	def self.const_load(object, const_name_space)
		unless @const_defined[const_name_space] then
			WIN32OLE.const_load(object, const_name_space)
			@const_defined[const_name_space] = true
		end
	end
end

module Excel
	def open_read xls_file
		open_excel(xls_file){|excel, workbook|
			yield excel, workbook
		}
	end
	
	def open_rw tmp_xls, dest_xls
		puts "+Writing into Excel file..."
		STDOUT.flush
		open_excel(tmp_xls){|excel, workbook|
			yield workbook
			begin
				#~ p dest_xls
				workbook.saveas "#{FileUtils.pwd}/#{dest_xls}".gsub(/\//, "\\")
				#~ workbook.close true
			rescue WIN32OLERuntimeError =>e
				puts "File '#{FileUtils.pwd}/#{dest_xls}' is using, please close it first!, Enter:Continue, X:Exit."
				STDOUT.flush
				if $stdin.gets=~/^x$/i
				else
					retry
				end
			rescue StandardError =>e
				p e
			#~ ensure
				#~ excel.Application.quit
			end
			#~ excel.quit
		}
	end
protected
	def open_excel xls_file
		excel = WIN32OLE.new('Excel.Application')
		excel.DisplayAlerts = false

		#~ excel.visible = TRUE
		workbook = excel.Workbooks.open('Filename'=>"#{FileUtils.pwd}/#{xls_file}", 'ReadOnly'=>true)
		begin
			yield excel, workbook
		ensure
			workbook.Close
			excel.Application.quit
		end
	end
end

class CExcel
include Excel
end

class CExcel2<CExcel
	def write_area sht, start_cell, arrays,  copy_style=true
		rg = sht.range(start_cell)
		ExcelConst.const_load(rg, Range)
		if copy_style
			rg.EntireRow.Copy()
			tgt_rg = sht.range(sht.Cells(rg.row+1, rg.column), sht.Cells(rg.row+arrays.size-1, rg.column)).EntireRow
			tgt_rg.EntireRow.PasteSpecial(Range::XlPasteFormats)
		end
		arrays.each{|row|
			rg_row = rg
			row.each{|col|
				rg_row.value2 = col
				rg_row = rg_row.offset(0, 1)
			}
			rg=rg.offset(1)
		}
		sht.Cells.EntireColumn.AutoFit if copy_style
	end

	def write_area_highlight sht, start_cell, arrays, copy_style=true #arrays[0]==true high light
		rg = sht.range(start_cell)
		ExcelConst.const_load(rg, Range)
		if copy_style
			rg.EntireRow.Copy()
			tgt_rg = sht.range(sht.Cells(rg.row+1, rg.column), sht.Cells(rg.row+arrays.size, rg.column)).EntireRow
			tgt_rg.EntireRow.PasteSpecial(Range::XlPasteFormats)
		end
		arrays.each{|row|
			rg_row = rg
			hl=false
			row.each_with_index{|col, index|
				if 0==index
					hl=col
				else
					if col.class==String
						rg_row.value2 = col
					elsif col.class==Array
						rg_row.value2 = col[0]
						sht.Hyperlinks.Add rg_row, col[1]
#~ ActiveSheet.Hyperlinks.Add Anchor:=Selection, Address:= "files\A\ITC_FISReport_SP_Sync.txt", TextToDisplay:="A"						
					end
					rg_row = rg_row.offset(0, 1)
				end
			}
			if hl #high light this line
				line=sht.range(rg, rg.offset(0, row.size-2))
				line.Interior.Color = 255
				line.Font.ThemeColor = Range::XlThemeColorDark1
			end
			rg=rg.offset(1)
		}
		sht.Cells.EntireColumn.AutoFit if copy_style
	end

	def write_table sht, start_cell, arrays, style=2
		#~ rg = sht.range(start_cell)
		# p start_cell
		rg=start_cell
		rg_row=nil
		ExcelConst.const_load(rg, Range)
		arrays.each{|row|
			rg_row = rg
			row.each{|col|
				rg_row.value2 = col
				rg_row = rg_row.offset(0, 1)
			}
			rg=rg.offset(1)
		}
		sht.Cells.EntireColumn.AutoFit

		tb=sht.ListObjects.Add(1, sht.Range(start_cell, rg_row.offset(0, -1)), nil, 1) #.Name =table
		#~ puts tb.name
		tb.TableStyle = "TableStyleMedium#{style}"
		tb.ShowHeaders = 1
		# tb.DisplayName='lwang'
		sht.Range(start_cell, rg_row.offset(1, -1)).HorizontalAlignment =  -4108
	end
end


if __FILE__==$0
	t1 = Time.new
  
	#~ CExcel.new('Template.xlsx', 'abc.xlsx'){|wb|
		#~ wb.Worksheets('Total_parts').range('B6').value='abcxyz'
	#~ }
	
	#~ CExcel.new.open_read('Template.xlsx'){|wb|
		#~ wb.Worksheets(1).usedrange.value2.each{|row|
			#~ p row
		#~ }
	#~ }

	excel = CExcel2.new
	excel.open_rw('template.xlsx', 'output_xls'){|wb|
		sht = wb.worksheets(1)
		#~ excel.write_area_highlight sht, 'A3', [[true, ['a', 'files\A\ITC_FISReport_SP_Sync.txt'], 'b'],[false, 'c','d'],[true, 'cc','dd']]
		excel.write_table sht, sht.Range('A3'), [[true, ['a', 'files\A\ITC_FISReport_SP_Sync.txt'], 'b'],[false, 'c','d'],[true, 'cc','dd']]
	}
	puts "time #{Time.new - t1} is spent."
end


