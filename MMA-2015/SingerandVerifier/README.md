#Singer and Verifier

Category: Crypto Points: 100 Solves: 92 Description:  
Signer: nc cry1.chal.mmactf.link 44815  
Verifier: nc cry1.chal.mmactf.link 44816  

Author: zywu@Bamboofox  
Email: w.zongyu@gmail.com  

**Problem Descirption**  
There is two server. One for sign the message, one for verify the signature. This is about general idea of [digital signature](https://en.wikipedia.org/wiki/Digital_signature). If you connect to the signer server, you will have something like this:  
**Since the server is closed. We take the following server information from [here](https://github.com/smokeleeteveryday/CTF_WRITEUPS/tree/master/2015/MMACTF/crypto/signerverifier)**  

```
$nc cry1.chal.mmactf.link 44815
1234
126500963383535523362422924813570198504368489400746397031182274029742549857996545699890486143555204412107191370721377288720744197999437743673395598519189494683098886868733633814783755962191762295825481720826404197724774063414955423222607128807811029259753833850658565679707331824250463952223440882461917812348
```  
This is clear that you give the signer server input "1234". Server will trun back with Sign("1234"). So now look t the verifier server.  

```
$nc cry1.chal.mmactf.link 44816
n = 167891001700388890587843249700549749388526432049480469518286617353920544258774519927209158925778143308323065254691520342763823691453238628056767074647261280532853686188135635704146982794597383205258532849509382400026732518927013916395873932058316105952437693180982367272310066869071042063581536335953290566509
e = 65537
Sign it!
107108056963926119307653689154379598833550598031154162917162315758527187945122022207634177035686529281496908832607092667606369706299100204708802542148796371841158674597117510610317948171940682385931628021629686
```  
The goal is to sign the message that verifier server gave. Then, that is trivial right? We can open two port and first take the message m (which need to be signed from verifier) then send to signer server and back to verifier? So that us do it!!!  

```
$nc cry1.chal.mmactf.link 44815
107108056963926119307653689154379598833550598031154162917162315758527187945122022207634177035686529281496908832607092667606369706299100204708802542148796371841158674597117510610317948171940682385931628021629686
By the way, I'm looking forward to the PIDs subsystem of cgroups.
```  

Uh... We will got this if you send the message need to be signed to the signer server. If you are very familiar with [RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem)). Then it will found out it is very likely to be the same idea of [RSA Chosen Cipher Attack](https://github.com/zongyuwu/RSA_ChosenCiphertextAttack) or some idea of blinding.  
I will explain the core idea of the attack following:  
This is the target message we want server to be signed  
![image](https://github.com/zongyuwu/CTFWriteUp/blob/master/MMA-2015/SingerandVerifier/Tex2Img_1441676759.jpg)
So we choose some x which is coprime to N. (If you are not familiar Read: [Modular Inverse](https://en.wikipedia.org/wiki/Modular_multiplicative_inverse)  
![image](https://github.com/zongyuwu/CTFWriteUp/blob/master/MMA-2015/SingerandVerifier/Tex2Img_1441677090.jpg)  
Then send M' to singer server to get SigM'. So how to retrive the SigM by SigM'  
![image](https://github.com/zongyuwu/CTFWriteUp/blob/master/MMA-2015/SingerandVerifier/Tex2Img_1441677267.jpg)  
![image](https://github.com/zongyuwu/CTFWriteUp/blob/master/MMA-2015/SingerandVerifier/Tex2Img_1441677344.jpg)  
![image](https://github.com/zongyuwu/CTFWriteUp/blob/master/MMA-2015/SingerandVerifier/Tex2Img_1441677381.jpg)  
SigM is recovered. Send it to Verifier server for flag!  
  
The exp.rb is the exploit code to finished the attack.  

This is a good example of exploit when the system is not padding. **You should padding securly when using RSA**


