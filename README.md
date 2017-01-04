# README

This version of the Book Beep web portal is running on Rails 4.3.7 without active record.

##Book Beep Product Plan

##What is Book Beep?
Book Beep is a mobile app and web portal for use by library volunteers at a non-profit organization. Initially it will help the organization to catalogue their books and make the library searchable on the web. The benefit to have a catalogue of books is that it can be shared to similar organizations around the world, and it would be easier to create wish lists for new books. Eventually Book Beep will also allow librarians to check books in and out of the library and maintain a system to send out reminders to the library users for checked out books at the end of the season.



## Market Research
- [Book Catalogue](https://lh4.ggpht.com/HOxLyKQA4eMsOrbd1cmdD7TwJ_tdRju-yi3WxUXQrO_FV6iVQiQRyvbJpEvxAFoSmWhN=w300-rw)  
    - An app with a lot more information per book than intended for BookBeep. It searches Amazon/Goodreads/Google Booksfor ISBN so a lot of books are covered and it is possible to list them too. The interface is a lot busier than I am looking to create, and there is no obvious way of sending the books to the cloud and therefore make use of the web portal in Book Beep.  

- [Libib](https://www.libib.com/)  
    - Sign up for a cloud based catalogue, similar to Book Beep, but only books published in the US are covered and my app is targeting the Swedish School Association Library which only has books from Sweden. Lending is included for a small price.  

- Other apps that scan books could not identify my sample selection of books. I also found barscanning slow, which might mean I need to learn the technique to do it faster, or be careful which barcode scanner I choose in my project.

## User Personas  
Volunteers at the organization's library, the librarians, are the target users of Book Beep. Their concerns are:
  - Time: They are short on time and new books can take weeks before they enter the system.
  - Connection with their borrowers: The librarians time is spent on the old card based system finding the young borrowers names in card boxes and noting down which item they borrowed. The organization see great benefits for the children's language development if librarians can spend a few minutes talking to the children about their choices, or their lives.    

## Technology  
- Google Android Studio (android app)   
- AWS Cognito    
- AWS DynamoDB   
- Ruby on Rails  (web portal)
- AWS Elastic Beanstalk (for deploying portal in the cloud)
- AWS EC2 & S3 (automatically used in deploy)  
- Amazon AWS SDK (Libraries for AWS resources to work seamlessly)     
<img https://1.bp.blogspot.com/-V1ejTVN9RkU/V0X_dSW-oNI/AAAAAAAAAdE/mn7lFWVV2cUhjN7f0-JL8EP7y344x-XzQCLcB/s1600/android-studio-logo.png>   
<img https://d7umqicpi7263.cloudfront.net/img/product/292b66af-d1c1-498f-bb10-433d911716ae/4f46367c-309a-4c1b-8e28-19cbeacb519c.png>  
<img http://perfectial.com/wp-content/uploads/2015/02/ruby.png>

## Links  
[Book Beep android app on Github](https://github.com/mimyal/BookBeepApp)  
[Swedish School Association](http://skolforeningen.org/)  
[Trello Board](https://trello.com/b/I8umPkGn/book-beep)    
[]()  
