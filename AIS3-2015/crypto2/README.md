#Crypto 2  

作者：zywu@Bamboofox
信箱：w.zongyu@gmail.com

這是一題很標準的古典密碼學的CTF題目，根據前人的writeup，這種題目在以前常常出現，如果有興趣可以看一下，或是找我討論一下！我會盡量把題目解釋清楚，請多指教！

**題目**  
非常清楚的就是個AES-OFB的加密，[AES(Advanced Encryption Standard)](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)是NIST公開徵選用來取代[DES(Data Encryption Standard)](https://en.wikipedia.org/wiki/Data_Encryption_Standard)的加密方式。我們可以視AES為一個[PRNG(PseudoRandom Number Generator)](https://en.wikipedia.org/wiki/Pseudorandom_number_generator)　　

![image](https://github.com/zongyuwu/CTFWriteUp/blob/master/AIS3-2015/crypto2/source/aes.JPG)

不管輸入的分佈如何，很可能是一個常態分布(normal distribution)，只要經過AES這個PRNG出來的結果就會是一個**幾乎無法與True Random Number Generator所產生結果區分**，輸出會是一個非常非常非常接近平均分佈(uniform distribution)的結果。但是他是一個Determinstic Algorithm，所以只要有相同的輸入就會走到相同的輸出！至於為甚麼要產生平均亂數呢？結論是**任何分部 XOR 平均分佈 = 平均分佈**。  
舉例，AES產生50%的bit 0，50%的bit 1。而你的明文分佈為70%的bit 0，30%的bit 1：
```
1 = 0 xor 1 + 1 xor 0 = 0.5*0.3 + 0.5*0.7 = 0.5
0 = 0 xor 0 + 1 xor 1 = 0.5*0.7 + 0.5*0.3 = 0.5
```
我們可以利用key當作AES的輸入並產生亂數用來加密我們的明文，最後的分佈不會透露任何訊息！以上大概是AES的慨念。

我們看一下題目可以發現這是一個AES-OFB mode，為了效率與方便性AES產生的PRNG長度規定在128, 192, 256 bits，也就是所謂的AES Block Size，如果要加密的文章超過Block Size又開怎麼辦呢？於是[Block Cipher Mode](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation)就是來解決這個問題，許多不同的mode定義如果串接上下block。本題的OFB  
![image](https://github.com/zongyuwu/CTFWriteUp/blob/master/AIS3-2015/crypto2/source/AES-OFB.JPG)  
我們知道的
```python
flag = "ais3{NEVERPHDNEVERPHDNEVERPHD..}" # Not real flag ...
```
  * Flag = "ais3{??????????????????????????}" 長度32bytes = 256 bits
  * **如果長度不是128, 192, 256需要padding補到block size**
```python
p = ''.join(random.choice(string.lowercase) for _ in range(32))
```
  * Plaintext = [a-z]隨機挑選32個　　
  
不知道的
```python
iv = ''.join(random.choice(string.hexdigits) for _ in range(16))
```
  * IV (initial vector)；可視為AES的參數之一，為了達到相同的key相同明文加密結果不一樣
```python
key = "XXXXXXXXXXXXXXXX"
```
  * key 完全不知道


  
來看一下AES有沒有弱點？  [(wiki)](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)  
Attacks have been published that are computationally faster than a full brute force attack, though none as of 2013 are computationally feasible.[3]  
For AES-128, the key can be recovered with a computational complexity of 2126.1 using the biclique attack. For biclique attacks on AES-192 and AES-256, the computational complexities of 2189.7 and 2254.4 respectively apply. Related-key attacks can break AES-192 and AES-256 with complexities 2176 and 299.5, respectively.  
看起來複雜度還是太高，我們再來看看我們有什麼資訊吧，先放棄這一條路。  
  
如果你仔細看原始碼你會發現，在連線建立時他就會將key與iv給準備好，然後後面所以有加密都是利用相同的(key, iv)。非常好，所以可以得到一個結論就是**在同一個連線內，AES輸出都會是同一組亂數**。逆推IV和Key，別傻了AES可沒那麼弱，阿應該說如果你可以很有效率的逆推，你會被寫在教科書內。換個方是想吧，我們已經知到 fix_R xor Plaintext = Ciphertext，fix_R不知道，Ciphertext知道，如果Plaintext可控或是知道那就簡單啦。可惜是我們只知道Plaintext他是一個[a-z]隨機挑32個字串，那那那該怎麼辦呢？洞洞腦喔不是，應該是動動腦！  
猜一下  
![image](https://github.com/zongyuwu/CTFWriteUp/blob/master/AIS3-2015/crypto2/source/Guess.JPG)  
如果猜對了  
![image](https://github.com/zongyuwu/CTFWriteUp/blob/master/AIS3-2015/crypto2/source/guess_right.JPG) 
  
**Plaintext[i] 是a-z，如果不符合表示我們猜錯了！，全部的測試資料都通過表示猜中的機率很高**
如果我們可以拿到越多的Ciphertext就可以越容易驗證我們的猜測是對的，這裡用50-100組就可以找正確的AES輸出了！  
```ruby
#prove 50 times to collect more information
50.times do 
  S.puts ""
  arr << S.gets.chomp
  S.gets
end

(0..31).map { |x| x*2 }.each do |i| #loop through 32 bytes in hex
  (0..255).each do |k|  #guess 0 to 255
    con = true
    arr.each do |a|
      tar = "#{a[i..i+1]}".to_i(16) ^ k  #test guess ^ cipher is between [a-z]
      if !(tar >= 0x61 && tar <= 0x7a) # if doesnot fit then test next guess
        con = false
        break
      end
    end
    # if pass all test then the guess is almost right
    puts (k ^ "#{flag[i..i+1]}".to_i(16)).chr if con == true
end
```

