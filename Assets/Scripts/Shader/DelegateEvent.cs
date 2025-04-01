using UnityEngine;
using System;
using UnityEngine.UIElements;
using Unity.UI;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine.Networking.PlayerConnection;





public class DelegateEvent : MonoBehaviour
{
    public class TestHandler
    {
        public event EventHandler NumberEventHandler;

        void Start()
        {
            NumberEventHandler += Test;
            NumberEventHandler.Invoke(this, EventArgs.Empty);

        }

        void Test(object sender, EventArgs e)
        {
            Debug.Log("TEST");
        }


    }
    
    public class SubTest : TestHandler
    
    {

        public string _name;

    
    }
}
