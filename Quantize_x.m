function x  = Quantize_x(Power_Total, Num_BS_Antennas, x)
        output = sqrt(Power_Total/(2 * Num_BS_Antennas));
        for temp = 1:Num_BS_Antennas
            if real(x(temp)) >= 0
                if  imag(x(temp)) >= 0
                    x(temp) = output + i * output;
                else
                    x(temp) = output - i * output;
                end
            else
                 if  imag(x(temp)) >= 0
                    x(temp) = -output + i * output;
                 else
                    x(temp) = -output - i * output;
                 end
            end
        end
end