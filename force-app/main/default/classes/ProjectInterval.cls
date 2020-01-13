global Class ProjectInterval implements Schedulable
{
  public static String CRON_EXP = '0 0 1 ? * * *';
  
  global static String scheduleIt() 
  {
    ProjectInterval PI = new ProjectInterval();
    return System.schedule('Daily Project Re-Calc', CRON_EXP, PI);
  }

  global void execute(SchedulableContext ctx)
  {
    calculateAllDueDate();
  }

  public static date BlankDate(date primary,date secondary)
  {
    date answer;
    if (primary != null)
    {
      answer = primary;
      return(answer);
    }
    answer = secondary;
    return(answer);
  }
  
  public static date getMaxDate(date primary,date secondary,integer interval)
  {
    date answer;
    if (primary != null)
    {
      answer = primary;
      return(answer);
    }
    if (secondary == null)
    {
      return(date.today());
    }
    if (date.today() > secondary.addDays(interval))
    {
      answer = date.today();
      return(answer);
    }
    answer = secondary.addDays(interval);
    return(answer);
  }
  
  public static date MaxDate(date primary,date secondary)
  {
    date answer;
    answer = primary;
    if (secondary > answer)
    {
      answer = secondary;
    }
    return(answer);
  }
  
  public static date MaxDate(date primary,date secondary,date tertiary)
  {
    date answer;
    answer = MaxDate(primary,secondary);
    answer = MaxDate(answer,tertiary);
    return(answer);
  }
  
  public static void calculateAllDueDate()
  {
    List<Project__c> Projects = new List <Project__c>();
    Projects = [Select id,
    osp_Build_Status__c,
    osp_Standard_Interval__c,
    Calculated_Interval__c,
    Telco_Pole_App_Required__c,
    Telco_MR_Req__c,
    Elco_Pole_App_Required__c,
    Elco_MR_Req__c,
    Other_Pole_App_Required__c,
    Other_MR_Req__c,
    osp_Poles__c,
    osp_Survey__c,
    osp_Submit__c,
    osp_MFC_Rcvd_Date__c,
    Telco_SentPA__c,
    Elco_SentPA__c,
    Other_SentPA__c,
    Telco_MR_EstRcvd__c,
    Elco_MR_EstRcvd__c,
    Other_MR_EstRcvd__c,
    Telco_MR_Check_Sent__c,
    Elco_MR_Check_Sent__c,
    Other_MR_Check_Sent__c,
    Telco_MR_Cmpltd__c,
    Elco_MR_Cmpltd__c,
    Other_MR_Cmpltd__c,
    osp_SentContractor__c,
    osp_Actual_Completion_Date__c    
    from Project__c];
    update Projects;
  }
  
  public static void calculateDueDate(Project__c[] projects)
  {
    integer Interval_SurveyReturned = 7;
    integer Interval_MFC_IC = 10;
    integer Interval_SOW_Apps_Pay = 7;
    integer Interval_MR_Est = 45;
    integer Interval_Pay_MR = 7;
    integer Interval_CompleteMakeReady = 45;
    integer Interval_SendtoContrctr = 2;
    integer Interval_Build = 21;
    integer MultiPole;
    boolean NO_MakeReady;
 
    boolean TelcoPoleAppReq;
    boolean TelcoMakeReadyReq;
    boolean ElcoPoleAppReq;
    boolean ElcoMakeReadyReq;
    boolean OtherPoleAppReq;
    boolean OtherMakeReadyReq;
    
    date Date_SurveyReturned;
    date Date_MFC_IC;
    date Date_Sow_Apps_Pay;
    date Date_MR_Est;
    date Date_Pay_MR;
    date Date_CompleteMakeReady;
    date Date_SendtoContrctr;
    date Date_Build;
    
    date Max_of_Sent_Pole_Apps;
    date Max_of_Est_and_Max_of_Rcvd;
    date Max_of_Est_and_Max_of_Sent;
    date Max_of_Est_and_Max_of_Cmpltd;
    
    date D_Trcv;
    date D_Ercv;
    date D_Orcv;
    date D_Tsnt;
    date D_Esnt;
    date D_Osnt;
    date D_Tcmp;
    date D_Ecmp;
    date D_Ocmp;
 
    for (Project__c Proj:  projects)
    {
      System.Debug(Proj.id);
      if (String.isBlank(Proj.osp_Build_Status__c))
      {
        Proj.Calculated_Interval__c = Proj.osp_Standard_Interval__c;
      }
      else
      {
        TelcoPoleAppReq = (!((String.isBlank(Proj.Telco_Pole_App_Required__c)) || (Proj.Telco_Pole_App_Required__c.charAt(0) == 'N'.charAt(0))));
        TelcoMakeReadyReq = (!((String.isBlank(Proj.Telco_MR_Req__c)) || (Proj.Telco_MR_Req__c.charAt(0) == 'N'.charAt(0))));
        ElcoPoleAppReq = (!((String.isBlank(Proj.Elco_Pole_App_Required__c)) || (Proj.Elco_Pole_App_Required__c.charAt(0) == 'N'.charAt(0))));
        ElcoMakeReadyReq = (!((String.isBlank(Proj.Elco_MR_Req__c)) || (Proj.Elco_MR_Req__c.charAt(0) == 'N'.charAt(0))));
        OtherPoleAppReq = (!((String.isBlank(Proj.Other_Pole_App_Required__c)) || (Proj.Other_Pole_App_Required__c.charAt(0) == 'N'.charAt(0))));
        OtherMakeReadyReq = (!((String.isBlank(Proj.Other_MR_Req__c)) || (Proj.Other_MR_Req__c.charAt(0) == 'N'.charAt(0))));
        NO_MakeReady = (!(TelcoPoleAppReq || TelcoMakeReadyReq || ElcoPoleAppReq || ElcoMakeReadyReq || OtherPoleAppReq || OtherMakeReadyReq));
        if (Proj.osp_Poles__c == 0)
        {
          MultiPole = 0;
        }
        else
        {
          MultiPole = 1;
          if (NO_MakeReady)
          {
            MultiPole = 0;
          }    
        }
        Date_SurveyReturned = getMaxDate(Proj.osp_Survey__c,Proj.osp_Submit__c,Interval_SurveyReturned);
        Date_MFC_IC = getMaxDate(Proj.osp_MFC_Rcvd_Date__c,Date_SurveyReturned,Interval_MFC_IC);
        
        Max_of_Sent_Pole_Apps = Proj.Telco_SentPA__c;
        
        if ((Max_of_Sent_Pole_Apps == null) || (Proj.Elco_SentPA__c > Max_of_Sent_Pole_Apps))
        {
          Max_of_Sent_Pole_Apps = Proj.Elco_SentPA__c;
        }
        if ((Max_of_Sent_Pole_Apps == null) || (Proj.Other_SentPA__c > Max_of_Sent_Pole_Apps))
        {
          Max_of_Sent_Pole_Apps = Proj.Other_SentPA__c;
        }
        Date_SOW_Apps_Pay = getMaxDate(Max_of_Sent_Pole_Apps,Date_MFC_IC,Interval_SOW_Apps_Pay);
        
        D_Trcv = null;
        if ((Proj.Telco_MR_Req__c != 'NO') && (Proj.Telco_Pole_App_Required__c == 'YES'))
        {
          if (Proj.Telco_MR_EstRcvd__c == null)
          {
            D_Trcv = Date_SOW_Apps_Pay.addDays(MultiPole * Interval_MR_Est);
            if (date.today() > D_Trcv)
            {
              D_Trcv = date.today();
            }
          }
          else
          {
            D_Trcv = Proj.Telco_MR_EstRcvd__c;
          }
        }
        
        D_Ercv = null;
        if ((Proj.Elco_MR_Req__c != 'NO') && (Proj.Elco_Pole_App_Required__c == 'YES'))
        {
          if (Proj.Elco_MR_EstRcvd__c == null)
          {
            D_Ercv = Date_SOW_Apps_Pay.addDays(MultiPole * Interval_MR_Est);
            if (date.today() > D_Ercv)
            {
              D_Ercv = date.today();
            }
          }
          else
          {
            D_Ercv = Proj.Elco_MR_EstRcvd__c;
          }
        }
        
        D_Orcv = null;
        if ((Proj.Other_MR_Req__c != 'NO') && (Proj.Other_Pole_App_Required__c == 'YES'))
        {
          if (Proj.Other_MR_EstRcvd__c == null)
          {
            D_Orcv = Date_SOW_Apps_Pay.addDays(MultiPole * Interval_MR_Est);
            if (date.today() > D_Orcv)
            {
              D_Orcv = date.today();
            }
          }
          else
          {
            D_Orcv = Proj.Other_MR_EstRcvd__c;
          }
        }
        
        Max_of_Est_and_Max_of_Rcvd = MaxDate(D_Trcv,D_Ercv,D_Orcv);
        
        if (Max_of_Est_and_Max_of_Rcvd == null)
        {
          Date_MR_Est = Date_SOW_Apps_Pay;
        }
        else
        {
          Date_MR_Est = Max_of_Est_and_Max_of_Rcvd;
          if (date.today() > Date_MR_Est)
          {
            Date_MR_Est = date.today();
          }
        } 
        
        D_Tsnt = null;
        if (Proj.Telco_MR_Req__c == 'YES')
        {
          D_Tsnt = BlankDate(Proj.Telco_MR_Check_Sent__c,MaxDate(date.today(),Date_MR_Est.addDays(MultiPole * Interval_Pay_MR)));
        }
           
        D_Esnt = null;
        if (Proj.Elco_MR_Req__c == 'YES')
        {
          D_Esnt = BlankDate(Proj.Elco_MR_Check_Sent__c,MaxDate(date.today(),Date_MR_Est.addDays(MultiPole * Interval_Pay_MR)));
        }
        
        D_Osnt = null;
        if (Proj.Other_MR_Req__c == 'YES')
        {
          D_Osnt = BlankDate(Proj.Other_MR_Check_Sent__c,MaxDate(date.today(),Date_MR_Est.addDays(MultiPole * Interval_Pay_MR)));
        }
        Max_of_Est_and_Max_of_Sent = MaxDate(D_Tsnt,D_Esnt,D_Osnt);
        if (Max_of_Est_and_Max_of_Sent == null)
        {
          Date_Pay_MR = Date_MR_Est;
        }
        else
        {
          Date_Pay_MR = MaxDate(Max_of_Est_and_Max_of_Sent,Date_MR_Est);
        } 
        
        D_Tcmp = null;
        if (Proj.Telco_MR_Req__c == 'YES')
        {
          D_Tcmp = BlankDate(Proj.Telco_MR_Cmpltd__c,MaxDate(date.today(),Date_Pay_MR.addDays(MultiPole * Interval_CompleteMakeReady)));
        }
        D_Tcmp = BlankDate(Proj.Telco_MR_DD__c,D_Tcmp);
           
        D_Ecmp = null;
        if (Proj.Elco_MR_Req__c == 'YES')
        {
          D_Ecmp = BlankDate(Proj.Elco_MR_Cmpltd__c,MaxDate(date.today(),Date_Pay_MR.addDays(MultiPole * Interval_CompleteMakeReady)));
        }
        D_Ecmp = BlankDate(Proj.Elco_MR_DD__c,D_Ecmp);
        
        D_Ocmp = null;
        if (Proj.Other_MR_Req__c == 'YES')
        {
          D_Ocmp = BlankDate(Proj.Other_MR_Cmpltd__c,MaxDate(date.today(),Date_Pay_MR.addDays(MultiPole * Interval_CompleteMakeReady)));
        }
        D_Ocmp = BlankDate(Proj.Other_MR_DD__c,D_Ocmp);
        
        Max_of_Est_and_Max_of_Cmpltd = MaxDate(D_Tcmp,D_Ecmp,D_Ocmp);
        if (Max_of_Est_and_Max_of_Cmpltd == null)
        {
          Date_CompleteMakeReady = Date_Pay_MR;
        }
        else
        {
          Date_CompleteMakeReady = MaxDate(Max_of_Est_and_Max_of_Cmpltd,Date_Pay_MR);
        } 
        
        Date_SendtoContrctr = getMaxDate(Proj.osp_SentContractor__c,Date_CompleteMakeReady,Interval_SendtoContrctr);
        Date_Build = getMaxDate(Proj.osp_Actual_Completion_Date__c,Date_SendtoContrctr,Interval_Build);
        if ((Proj.osp_Build_Status__c.length() < 7) || (Proj.osp_Build_Status__c.substring(0,7) != 'Step 7:'))
          {
            Proj.Calculated_Interval__c = Date_Build;
          }
        
      }
    }

  }

}