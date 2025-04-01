using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Enemy : MonoBehaviour
{
    private bool FindPlayer = false;
    private Vector3 lastknownPlayerPosition;
    void Start()
    {
        LinkInfo();
    }


    private void Update()
    {
        if(!FindPlayer)
        {
            DetectPlayer();
        }
        else
        {
            ChasePlayer();
        }
    }

    private void DetectPlayer()
    {
       
            Collider[] hitColliders = Physics.OverlapSphere(transform.position, 3f); // 10m 범위 탐색

        foreach (Collider col in hitColliders)
        {
            if (col.CompareTag("Player")) // 플레이어가 범위 안에 있으면
                {
                Debug.Log(gameObject.name + "이(가) 플레이어를 발견했다!");
                FindPlayer = true;
                lastknownPlayerPosition = col.transform.position;

                // 모든 적에게 플레이어 발견 알림
                EventManger.FindPlayerEvent(lastknownPlayerPosition);
                break;
            }
            else { Debug.Log("순찰중입니다..."); }
            }
        }

    private void LinkInfo()
    {
        Debug.Log("아군과 정보를 링크합니다.");
        EventManger.OnPlayerFind += OnPlayerDetected; //시그니처가 동일하므로 체인해줄 수 있다.
    }

    private void OnPlayerDetected(Vector3 playerPosition)
    {
        if(!FindPlayer)
        {
            Debug.Log("정보를 제공받았습니다");
            FindPlayer = true;
            lastknownPlayerPosition = playerPosition;
        }

    }

     private void ChasePlayer()
    {
        if(FindPlayer == true)
        
        {
            Debug.Log("추격내용");
        }
       
    }

}
