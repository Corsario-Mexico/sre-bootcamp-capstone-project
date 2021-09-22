import math


class CidrMaskConvert:
    def cidr_to_mask(self, val):
        # Initializes the output variable
        str_mask = ""
        try:
            val_num = float(val)
            if not val_num.is_integer():
                return "Invalid"
            val_num = int(val_num)
            if (val_num <= 0) or (val_num > 32):
                raise ValueError
        except ValueError:
            return "Invalid"
        # Creates the full mask by creating a "val" number of ones and
        # "moving" them to the start of a 32 long bit number
        full_mask = ((2 ** val_num) - 1) << (32 - val_num)
        # Process the 4 different octets from last to first
        for step in range(0, 32, 8):
            # Gets the last 8 bits for the correponding octet
            octet_value = 255 & (full_mask >> step)
            # Transforms it to string and appends it at the front
            str_mask = str(octet_value) + "." + str_mask
        # Returns the full string mask except the last character, which is a "."
        return str_mask[:-1]

    def mask_to_cidr(self, val):
        # Initializes mask
        mask = 0
        # Parses the mask
        octets = val.split(".")
        # If not 4 octets is invalid
        if len(octets) != 4:
            return "Invalid"
        # Flag to know if the rest of the octets should be zero
        finished = False
        # For each octet
        for octet in octets:
            # If it has finished the rest of the octets must be 0
            if finished:
                if octet != "0":
                    return "Invalid"
            # If not
            else:
                # The only way to continue with the next octet is if the
                # current one is 255 and then we add 8 to the mask
                if octet == "255":
                    mask += 8
                # If not
                else:
                    # This shoudl be the last octet
                    finished = True
                    # Check the octet is an integer
                    try:
                        octet_value = float(octet)
                        if not octet_value.is_integer:
                            return "Invalid"
                    except ValueError:
                        return "Invalid"
                    # The value should be the complement to a base 2 number
                    octet_value = 256 - int(octet_value)
                    # If the number is out of bounds then is invalid
                    if (octet_value < 2) or (octet_value > 256):
                        return "Invalid"
                    # Calculates the power of two of the complement
                    power_of_2 = math.log(octet_value, 2)
                    # Checks if the complement is a power of two
                    if power_of_2.is_integer():
                        # If valid then add the complement to the mask
                        mask += 8 - int(power_of_2)
                    else:
                        # If it is not a power of two the value is invalid
                        return "Invalid"
        # If the mask is 0 then its an invalid value
        if mask == 0:
            return "Invalid"
        return str(mask)


class IpValidate:
    def ipv4_validation(self, val):
        # Parses the input
        octets = val.split(".")
        # If not 4 octets is invalid
        if len(octets) != 4:
            return False
        try:
            # For each octet
            for octet in octets:
                # Convert to integer
                octet_value = int(octet)
                if (octet_value < 0) or (octet_value >= 256):
                    raise ValueError
        except ValueError:
            return False
        return True
