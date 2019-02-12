module imageNOISE

# ---------------------------------
# IMAGE NOISE GENERATION
# ---------------------------------
# This module provides functions for the addition of controlled amounts of
# noise to an image, for use in the development of image filtering algorithms.
# The controlled degradation of noise-free images allows for easy comparison
# using the original image as the ground truth. Some types of noise are
# better suited to some types of filters, for example:
#
#    Gaussian noise -> mean filter
#    Impulse noise  -> median filter


# impulse()        - Function to add impulse noise
# gaussian()       - Function to add (additive) Gaussian noise
# raleigh()        -

# Also known as salt-and-pepper noise
# prob = probability of occurrence of salt (255) and pepper (0) noise
# The program assumes both salt and pepper are equally likely to occur.
# Normally occurs in images acquired from cameras with malfunctioning pixels.
# Salt-and-pepper noise is named after the back and white appearance it gives
# to images.
# "dead" pixels in a camera sensor
#
# returns a new image with added impulse noise

function impulse(img, prob)

    dx, dy = size(img)
    noisyImg = copy(img)

    noise = round(Int16,prob * 32768/2)
    noise1 = noise + 16384
    noise2 = 16384 - noise

    for i=1:dx, j=1:dy
        noise = rand(0:32767)
        if (noise >= 16384 && noise < noise1)
            noisyImg[i,j] = 0
        end
        if (noise >= noise2 && noise < 16384)
            noisyImg[i,j] = 255
        end
    end

    return noisyImg
end

# Gaussian noise is defined using a Gaussian histogram
# additive

# mean, variance

function gaussian(img, meanG=0, varG=800)

    dx, dy = size(img)
    noisyImg = copy(img)

    for i=1:dx, j=1:dy
        r = rand(0:32767)
        noise = sqrt(-2.0 * varG * log(1.0-r/32767.1))
        theta = rand(0:32767) * 1.9175345e-4 - 3.14159265
        noise = noise * cos(theta)
        noise = noise + meanG
        noisy = noisyImg[i,j] + noise
        if (noisy > 255)
            noisy = 255
        end
        if (noisy < 0)
            noisy = 0
        end
        noisyImg[i,j] = round(Int16, noisy)
    end

    return noisyImg

end

# Rayleigh type noise typically appears in radar range and velocity images
# and is derivable from uniform noise.
#

function raleigh(img, varG=600)

    dx, dy = size(img)
    noisyImg = copy(img)

    for i=1:dx, j=1:dy
        a = 2.3299 * varG
        r = rand(0:32767)
        noise = sqrt(-2 * a * log(1.0-r/32767.1))
        noisy = noisyImg[i,j] + noise
        if (noisy > 255)
            noisy = 255
        end
        if (noisy < 0)
            noisy = 0
        end
        noisyImg[i,j] = round(Int16, noisy)
    end

    return noisyImg
end

# Generate negative exponential noise
# It is the result of acquiring an image illuminated with a coherent
# laser, often referred to as laser speckle.

function speckle(img, varG=800)

    dx, dy = size(img)
    noisyImg = copy(img)

    for i=1:dx, j=1:dy
        a = sqrt(varG/2.0)
        r = rand(0:32767)
        noise = sqrt(-2 * a * log(1.0-r / 32767.1))
        theta = rand(0:32767) * 1.9175345e-4 - 3.14159265
        Rx = noise * cos(theta)
        Ry = noise * sin(theta)
        noise = Rx*Rx + Ry*Ry
        noisy = noisyImg[i,j] + noise
        if (noisy > 255)
            noisy = 255
        end
        if (noisy < 0)
            noisy = 0
        end
        noisyImg[i,j] = round(Int16, noisy)
    end

    return noisyImg
end

# Gamma noise is the result of lowpass filtering an image containing negative exponential
# noise
# additive

function gamma(img, varG=500, alpha=2)

    dx, dy = size(img)
    noisyImg = copy(img)
    a = sqrt(varG/alpha)/2.0

    for i=1:dx, j=1:dy
        noisy = 0.0
        for k=1:alpha
            noise = sqrt(-2 * a * log(1.0-rand(0:32767) / 32767.1))
            theta = rand(0:32767) * 1.9175345e-4 - 3.14159265
            Rx = noise * cos(theta)
            Ry = noise * sin(theta)
            noise = Rx*Rx + Ry*Ry
            noisy = noisy + noise
        end
        noisy = noisyImg[i,j] + noisy
        if (noisy > 255)
            noisy = 255
        end
        if (noisy < 0)
            noisy = 0
        end
        noisyImg[i,j] = round(Int16, noisy)
    end

    return noisyImg
end

#
function uniform(img, varG=800, meanG=0)

    dx, dy = size(img)
    noisyImg = copy(img)

    for i=1:dx, j=1:dy
        noise = sqrt(varG) * 1.057192e-4 * rand(0:32767) + meanG
                - sqrt(varG) * 1.7320508
        noisy = noisyImg[i,j] + noise
        if (noisy > 255)
            noisy = 255
        end
        if (noisy < 0)
            noisy = 0
        end
        noisyImg[i,j] = round(Int16, noisy)
    end

    return noisyImg
end



end
