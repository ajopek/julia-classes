import Base.*
import Base.convert
import Base.^
import Base.promote_rule
import Base.inv
import Base.reverse

struct Gn{N} <: Integer
    val :: Int
    function Gn(val)
         moduloX = val % N;
         if (gcd(moduloX, N) != 1 || moduloX <= 0)
            throw(DomainError)
         end
         new(moduloX)
    end
end

# Standard operators
function (*)(x::Gn{N}, y::Gn{N}) where {N}
    result = x.val * y.val;
    Gn{N}(result)
end

function (*)(x::Gn{N}, y::Int) where {N}
    convertedY = Gn{n}(y);
    convertedY * x
end

function (^)(x::Gn{N}, y::T) where {N, T <: Integer}
    (py, px) = promote(y, x);
    result = px;
    while py > 1
        result = result * result % N;
        py = py - 1;
    end
    Gn{N}(result)
end

# Type specific functions
function elements_number(::Type{Gn{N}}) where {N}
    result = 0;
    for element = 1:(N-1)
        if gcd(element, N) == 1
            result = result + 1;
        end
    end
    result
end
function period(x::Gn{N}) where {N}
    i = 1;
    power = x ^ i;
    elem_num = elements_number(Gn{N});
    while i < elem_num && power != 1
        i = i + 1;
        if rem(elem_num, i) == 0
            power = x ^ i;
        end
    end
    i
end

# Smallest y for which x * y mod N = 1
# Uses extended Euclidean algorithm
function reverse(x::Gn{N}) where {N}
     (a, b) = promote(x, N);
     q = 0;
     r = Array{Int64}(2); # reminder
     s = Array{Int64}(2);
     t = Array{Int64}(2);
     # Variables
     result = 0;
     # Initialization
     s[1] = 1;
     s[2] = 0;
     t[1] = 0;
     t[2] = 1;
     r[1] = a;
     r[2] = b;
     # Proper computation loop
     i = 1;
     while true
         next_elem = (i % 2) + 1;
         q = div(r[i], r[next_elem]);
         r[i] = r[i] - (q * r[next_elem]);
         s[i] = s[i] - (q * s[next_elem]);
         t[i] = t[i] - (q * t[next_elem]);
         if(r[i] == 0)
             result = s[next_elem];
             break;
         end
         i = next_elem;
     end
     # Result
     if result < 0
         result = N + result;
     end
     result
end
# Promotion rules
promote_rule(::Type{Gn{N}}, ::Type{T}) where {N, T <: Integer} = T
# Conversions
function convert(::Type{Int}, x::Gn{N}) where {N} x.val end
function convert(::Type{Gn{N}}, x::Int) where {N}
        Gn{N}(x)
end

# RSA encryption breaking test
# Public key N = 55, c = 17
# Encrypted message b = 4
function rsa_breaking_test()
        N = 55;
        c = 17;
        b = 4;
        message = Gn{N}(b);
        msg_period = period(message);
        private_key = reverse(Gn{msg_period}(c));
        decrypted_msg = Gn{55}(b) ^ private_key;

        # Encrypt decrypted message and check with original message b.
        encrypted_msg = decrypted_msg ^ private_key;
        encrypted_msg == decrypted_msg
end
