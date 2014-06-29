function ret = pretvori(input)
	var = input - '0';
	
	if (var >=  0 & var <=9 )
		ret = var + 1;
	end
	
	if (var >= 17 & var <= 42)
		ret = 11 + (var - 17);
	end
	
	if (var >=49 & var <=74)
		ret = 37 + (var - 49);
	end
end