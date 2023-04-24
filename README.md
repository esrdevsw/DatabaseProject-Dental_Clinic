# DatabaseProject-Dental_Clinic
 In this project we present the scripts for the construction of the database,
 from the creation of tables and the insertion of data.
 There are also typical queries in each step and searching for information for each type of table.

 To meet the business rules presented in the narrative, it was necessary to
 automate some tasks through procedures:

    NEW_PATIENT------->>> Insert the new patient data and check if the EirCode already exists in the address table
    NEW_PATIENT_DETAIL->> Enter the new patient's address data
    NEW_PATIENT_ALL---->> In a single command, insert the patient's data in both tables, if the EirCode already exists,
                          it searches for the reference key
    CHECK_DIARY ------->> Search available times to schedule an appointment. The daily table presents the appointment
                          data and the patient data as well as the available hours as a NULL value.
    WEEKS_APPOINTMENTS -> Searches appointments and available times to schedule an appointment with an interval of
                          7 days from the date of entry.
    SET_NEW_APPOINTMENT-> Schedule a new appointment
    DELETE_APPOINTMENTS-> This procedure deletes an appointment from the table and checks the date of the appointment,
                          if it is a cancellation on the same day as the appointment, then it generates an bill in the
                          amount of 10 euros.
    TREATMENT_RECORD -->> This procedure saves the treatment record and generates the respective Bill to be paid
    MAKE_PAYMENT ------>> The record of payments made is generated based on the bill ID, patient ID and the amount
                          to be paid. The procedure updates the amounts that the customer is paying from the
                          Bill and its payment status, thus enabling a control of small payments for the same Bill.

![image](https://user-images.githubusercontent.com/21969268/233992970-0da94bd3-fe03-4714-be30-3879b6a61c8b.png)
