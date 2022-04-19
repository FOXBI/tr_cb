# tr_cb
Tinycore Redpill Create Boot Image & USB<br>

# Requirement

 Tinycore, Build completion status<br>
 ![image](https://user-images.githubusercontent.com/42568682/164004204-b1ef8ba8-d678-48f4-8bd7-cff4b3786b92.png)


# Howto Run

1. Download attached file on your PC (tr_cb.tar)<br>
    or See the source page on github -> http://github.com/FOXBI/tr_cb

2. Start up your Tinycore and upload it. (using sftp....)<br>
    Alternatively, you can paste the source directly from the shell.<br>
    or wget, gitclone ...

3. Connect to ssh by tc account.

4. Progress as tc user. 

5. Build (rploader or tr_st,  ....)

6. Check Directory location
   > pwd /home/tc

7. Decompress file & check file:
   > tar xvf tr_cb.tar <br>
   > ls -lrt <br>
   > chmod 755 tr_cb.sh

8. Run to Source file
   > ./tr_cb.sh

When you execute it, proceed according to the description that is output.<br>

![image](https://user-images.githubusercontent.com/42568682/164004069-51b9773d-83a1-4cf4-9205-0ec61f17aae0.png)


[![tr_cb](http://img.youtube.com/vi/RnZ1v0SJQ3o/0.jpg)](https://youtu.be/RnZ1v0SJQ3o) 

# Additional notes

1. You can proceed only when the build has been completed.

2. In the case of USB, it will not proceed unless the USB is plugged in.

3. Please note that all data will be deleted in the case of USB.

4. In case of USB, it may take some time depending on the capacity.

5. In case of USB, VID and PID are automatically put in grub.cfg.

6. In the case of USB, the default is hd0, which is the default boot order.

7. Image is created in /home/tc/ in the form of model name_version.img and is quickly created in 150MB.

8. Image is changed to hd0 -> hd1 according to the boot order based on the environment being built.


# Finally comment

I'm an ESXi user, so the Native test is lacking.(Check only basic bootability)

Please note that there may be errors.

If you tell me the test results and points for improvement, I'll reflect them.
