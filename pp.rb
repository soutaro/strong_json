require "prettyprint"

pp = PrettyPrint.new

pp.group 0 do
	pp.text "hello = "

	pp.group 0, "enum_____(", ")" do
		pp.nest(2) do
			pp.breakable ""
			count = 7
			count.times do |i|
				pp.text "hello #{i}"

				if i < count - 1
					pp.text ","
					pp.breakable " "
				end
			end
		end

		pp.breakable ""
	end
end

pp.flush
puts pp.output
